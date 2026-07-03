//
//  AppConstants.swift
//  MyPomodoro
//

import Foundation

enum AppConstants {
    // MARK: - Timer defaults (focus-timer.md, settings.md)

    static let defaultFocusDurationMinutes = 25
    static let defaultBreakDurationMinutes = 5
    static let defaultFocusDurationSeconds = defaultFocusDurationMinutes * 60
    static let defaultBreakDurationSeconds = defaultBreakDurationMinutes * 60

    // MARK: - Daily goal default (settings.md)

    static let defaultDailyGoalMinutes = 120

    // MARK: - Input ranges (settings.md)

    static let focusDurationRange = 1...180
    static let breakDurationRange = 1...60
    static let dailyGoalRange = 10...720

    // MARK: - Subject (subject-selection.md)

    static let subjectNameMaxLength = 30
    static let subjectColorPresetCount = 6

    // MARK: - Study session (study-session-storage.md)

    static let minimumSessionDurationSeconds = 60
}
