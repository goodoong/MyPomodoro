//
//  SettingsViewModel.swift
//  MyPomodoro
//

import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var focusMinutes = AppConstants.defaultFocusDurationMinutes
    @Published var breakMinutes = AppConstants.defaultBreakDurationMinutes
    @Published var dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes
    @Published var subjects: [Subject] = []
    @Published var editingSubject: Subject?
    @Published var validationError: String?

    var settingsService: SettingsServiceProtocol
    let subjectService: SubjectServiceProtocol

    init(
        settingsService: SettingsServiceProtocol,
        subjectService: SubjectServiceProtocol
    ) {
        self.settingsService = settingsService
        self.subjectService = subjectService
    }

    func load() {
        do {
            focusMinutes = settingsService.focusDuration
            breakMinutes = settingsService.breakDuration
            dailyGoalMinutes = settingsService.dailyGoalMinutes
            subjects = try subjectService.fetchAll()
            validationError = nil
        } catch {
            validationError = error.localizedDescription
        }
    }

    func updateFocusMinutes(_ minutes: Int) {
        settingsService.focusDuration = minutes
        focusMinutes = settingsService.focusDuration
        validationError = nil
    }

    func updateBreakMinutes(_ minutes: Int) {
        settingsService.breakDuration = minutes
        breakMinutes = settingsService.breakDuration
        validationError = nil
    }

    func updateDailyGoal(_ minutes: Int) {
        settingsService.dailyGoalMinutes = minutes
        dailyGoalMinutes = settingsService.dailyGoalMinutes
        validationError = nil
    }

    func addSubject(name: String, colorHex: String) {
        do {
            _ = try subjectService.create(name: name, colorHex: colorHex)
            subjects = try subjectService.fetchAll()
            validationError = nil
        } catch {
            validationError = error.localizedDescription
        }
    }

    func updateSubject(_ subject: Subject, name: String, colorHex: String) {
        let originalName = subject.name
        let originalColorHex = subject.colorHex
        subject.name = name
        subject.colorHex = colorHex

        do {
            try subjectService.update(subject)
            subjects = try subjectService.fetchAll()
            validationError = nil
        } catch {
            subject.name = originalName
            subject.colorHex = originalColorHex
            validationError = error.localizedDescription
        }
    }

    func deleteSubject(_ subject: Subject) {
        do {
            try subjectService.softDelete(subject)
            subjects = try subjectService.fetchAll()
            if editingSubject?.id == subject.id {
                editingSubject = nil
            }
            validationError = nil
        } catch {
            validationError = error.localizedDescription
        }
    }
}
