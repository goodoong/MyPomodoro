//
//  TimerViewModel.swift
//  MyPomodoro
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var mode: TimerMode = .focus
    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = AppConstants.defaultFocusDurationSeconds
    @Published var selectedSubject: Subject?
    @Published var subjects: [Subject] = []
    @Published var canStart = false
    @Published var alertMessage: String?
    @Published var progressFraction: Double = 0

    let timerEngine: TimerEngineProtocol
    let sessionService: StudySessionServiceProtocol
    let subjectService: SubjectServiceProtocol
    let settingsService: SettingsServiceProtocol
    private var activeFocusStartedAt: Date?

    init(
        timerEngine: TimerEngineProtocol,
        sessionService: StudySessionServiceProtocol,
        subjectService: SubjectServiceProtocol,
        settingsService: SettingsServiceProtocol
    ) {
        self.timerEngine = timerEngine
        self.sessionService = sessionService
        self.subjectService = subjectService
        self.settingsService = settingsService
        self.mode = timerEngine.mode
        self.state = timerEngine.state
        self.remainingSeconds = timerEngine.remainingSeconds

        configureEngineCallbacks()
        syncDurationsFromSettings()
    }

    func load() {
        syncDurationsFromSettings()

        do {
            subjects = try subjectService.fetchAll()
            selectedSubject = subjectService.selectedSubject() ?? subjects.first
            if let selectedSubject {
                subjectService.setSelectedSubject(id: selectedSubject.id)
            }
            updateCanStart()
            alertMessage = nil
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func start() {
        guard let selectedSubject else {
            alertMessage = "과목을 먼저 선택해 주세요."
            updateCanStart()
            return
        }

        guard focusDurationSeconds > 0 else {
            alertMessage = "집중 시간이 올바르지 않습니다."
            updateCanStart()
            return
        }

        syncDurationsFromSettings()
        timerEngine.focusDurationSeconds = focusDurationSeconds
        timerEngine.breakDurationSeconds = breakDurationSeconds
        activeFocusStartedAt = Date()
        timerEngine.start(mode: .focus)
        syncEngineState()
        updateCanStart()
    }

    func pause() {
        timerEngine.pause()
        syncEngineState()
        updateCanStart()
    }

    func resume() {
        timerEngine.resume()
        syncEngineState()
        updateCanStart()
    }

    func stop() {
        timerEngine.stop()
        activeFocusStartedAt = nil
        syncEngineState()
        updateCanStart()
    }

    func selectSubject(_ subject: Subject?) {
        guard state != .running else {
            alertMessage = "타이머 실행 중에는 과목을 변경할 수 없습니다."
            return
        }

        selectedSubject = subject
        subjectService.setSelectedSubject(id: subject?.id)
        updateCanStart()
    }

    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            timerEngine.syncRemainingTime(now: Date())
            syncEngineState()
        case .inactive, .background:
            break
        @unknown default:
            break
        }
    }

    private var focusDurationSeconds: Int {
        settingsService.focusDuration * 60
    }

    private var breakDurationSeconds: Int {
        settingsService.breakDuration * 60
    }

    private func configureEngineCallbacks() {
        timerEngine.onTick = { [weak self] remainingSeconds in
            self?.remainingSeconds = remainingSeconds
            self?.syncEngineState()
        }
        timerEngine.onFocusCompleted = { [weak self] in
            self?.handleFocusCompleted()
        }
        timerEngine.onBreakCompleted = { [weak self] in
            self?.handleBreakCompleted()
        }
    }

    private func syncDurationsFromSettings() {
        timerEngine.focusDurationSeconds = focusDurationSeconds
        timerEngine.breakDurationSeconds = breakDurationSeconds
        if state == .idle {
            remainingSeconds = mode == .break ? breakDurationSeconds : focusDurationSeconds
        }
        updateProgressFraction()
    }

    private func syncEngineState() {
        mode = timerEngine.mode
        state = timerEngine.state
        remainingSeconds = timerEngine.remainingSeconds
        updateProgressFraction()
    }

    private func updateProgressFraction() {
        let totalSeconds = mode == .break ? breakDurationSeconds : focusDurationSeconds
        guard totalSeconds > 0 else {
            progressFraction = 0
            return
        }

        let elapsedSeconds = max(0, totalSeconds - remainingSeconds)
        progressFraction = min(max(Double(elapsedSeconds) / Double(totalSeconds), 0), 1)
    }

    private func updateCanStart() {
        canStart = state == .idle && selectedSubject != nil
    }

    private func handleFocusCompleted() {
        guard let selectedSubject, let startedAt = activeFocusStartedAt else {
            alertMessage = "집중 세션을 저장할 수 없습니다."
            activeFocusStartedAt = nil
            mode = .focus
            state = .idle
            remainingSeconds = focusDurationSeconds
            updateCanStart()
            return
        }

        let endedAt = Date()
        let durationSeconds = focusDurationSeconds

        do {
            try sessionService.saveCompleted(
                subjectId: selectedSubject.id,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds
            )
            activeFocusStartedAt = nil
            timerEngine.start(mode: .break)
            syncEngineState()
            updateCanStart()
        } catch {
            alertMessage = error.localizedDescription
            activeFocusStartedAt = nil
            mode = .focus
            state = .idle
            remainingSeconds = focusDurationSeconds
            updateCanStart()
        }
    }

    private func handleBreakCompleted() {
        activeFocusStartedAt = nil
        timerEngine.stop()
        mode = .focus
        state = .idle
        remainingSeconds = focusDurationSeconds
        updateCanStart()
    }
}
