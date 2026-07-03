//
//  SettingsService.swift
//  MyPomodoro
//

import Foundation
import SwiftData

@MainActor
final class SettingsService: SettingsServiceProtocol {
    private let modelContext: ModelContext
    private let defaults: UserDefaults

    private enum Key {
        static let focusDurationMinutes = "focusDurationMinutes"
        static let breakDurationMinutes = "breakDurationMinutes"
    }

    init(modelContext: ModelContext, defaults: UserDefaults = .standard) {
        self.modelContext = modelContext
        self.defaults = defaults
    }

    var focusDuration: Int {
        get {
            loadMinutes(
                forKey: Key.focusDurationMinutes,
                defaultValue: AppConstants.defaultFocusDurationMinutes,
                validRange: AppConstants.focusDurationRange
            )
        }
        set {
            saveMinutes(newValue, forKey: Key.focusDurationMinutes, validRange: AppConstants.focusDurationRange)
        }
    }

    var breakDuration: Int {
        get {
            loadMinutes(
                forKey: Key.breakDurationMinutes,
                defaultValue: AppConstants.defaultBreakDurationMinutes,
                validRange: AppConstants.breakDurationRange
            )
        }
        set {
            saveMinutes(newValue, forKey: Key.breakDurationMinutes, validRange: AppConstants.breakDurationRange)
        }
    }

    var dailyGoalMinutes: Int {
        get {
            do {
                return try fetchDailyGoal()?.targetMinutes ?? AppConstants.defaultDailyGoalMinutes
            } catch {
                return AppConstants.defaultDailyGoalMinutes
            }
        }
        set {
            let clampedValue = newValue.clamped(to: AppConstants.dailyGoalRange)
            do {
                try upsertDailyGoal(targetMinutes: clampedValue)
            } catch {
                // Keep the previously stored value on failure.
            }
        }
    }

    private func loadMinutes(forKey key: String, defaultValue: Int, validRange: ClosedRange<Int>) -> Int {
        let storedValue = defaults.object(forKey: key) as? Int
        let value = storedValue ?? defaultValue
        return value.clamped(to: validRange)
    }

    private func saveMinutes(_ value: Int, forKey key: String, validRange: ClosedRange<Int>) {
        defaults.set(value.clamped(to: validRange), forKey: key)
    }

    private func fetchDailyGoal() throws -> DailyGoal? {
        let descriptor = FetchDescriptor<DailyGoal>(
            sortBy: [SortDescriptor(\DailyGoal.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).first
    }

    private func upsertDailyGoal(targetMinutes: Int) throws {
        let descriptor = FetchDescriptor<DailyGoal>(
            sortBy: [SortDescriptor(\DailyGoal.updatedAt, order: .reverse)]
        )
        let existingGoals = try modelContext.fetch(descriptor)

        if let primaryGoal = existingGoals.first {
            primaryGoal.targetMinutes = targetMinutes
            primaryGoal.updatedAt = Date()

            if existingGoals.count > 1 {
                for duplicate in existingGoals.dropFirst() {
                    modelContext.delete(duplicate)
                }
            }
        } else {
            modelContext.insert(
                DailyGoal(
                    targetMinutes: targetMinutes,
                    updatedAt: Date()
                )
            )
        }

        try modelContext.save()
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
