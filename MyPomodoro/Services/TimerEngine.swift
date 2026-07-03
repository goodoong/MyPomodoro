//
//  TimerEngine.swift
//  MyPomodoro
//

import Foundation

@MainActor
final class TimerEngine: TimerEngineProtocol {
    var mode: TimerMode = .focus
    var state: TimerState = .idle
    var remainingSeconds: Int = AppConstants.defaultFocusDurationSeconds
    var sessionStartAt: Date?
    var focusDurationSeconds: Int = AppConstants.defaultFocusDurationSeconds
    var breakDurationSeconds: Int = AppConstants.defaultBreakDurationSeconds

    var onTick: ((Int) -> Void)?
    var onFocusCompleted: (() -> Void)?
    var onBreakCompleted: (() -> Void)?

    private var timer: Timer?
    private var plannedDurationSeconds: Int = AppConstants.defaultFocusDurationSeconds

    func start(mode: TimerMode) {
        stopTimer()
        self.mode = mode
        plannedDurationSeconds = duration(for: mode)
        remainingSeconds = plannedDurationSeconds
        sessionStartAt = Date()
        state = .running
        scheduleTimer()
        onTick?(remainingSeconds)
    }

    func pause() {
        guard state == .running else { return }
        stopTimer()
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        scheduleTimer()
    }

    func stop() {
        stopTimer()
        state = .idle
        sessionStartAt = nil
        remainingSeconds = duration(for: mode)
    }

    func syncRemainingTime(now: Date) {
        guard state == .running, let sessionStartAt else { return }

        let elapsedSeconds = Int(now.timeIntervalSince(sessionStartAt))
        let syncedRemainingSeconds = max(plannedDurationSeconds - elapsedSeconds, 0)
        remainingSeconds = syncedRemainingSeconds

        if syncedRemainingSeconds == 0 {
            handleCompletion()
        }
    }

    private func scheduleTimer() {
        stopTimer()
        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        guard let timer else { return }
        RunLoop.main.add(timer, forMode: .common)
    }

    private func tick() {
        guard state == .running else { return }

        remainingSeconds = max(remainingSeconds - 1, 0)
        onTick?(remainingSeconds)

        if remainingSeconds == 0 {
            handleCompletion()
        }
    }

    private func handleCompletion() {
        stopTimer()
        state = .idle
        sessionStartAt = nil
        remainingSeconds = 0

        switch mode {
        case .focus:
            onFocusCompleted?()
        case .break:
            onBreakCompleted?()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func duration(for mode: TimerMode) -> Int {
        switch mode {
        case .focus:
            return focusDurationSeconds
        case .break:
            return breakDurationSeconds
        }
    }
}
