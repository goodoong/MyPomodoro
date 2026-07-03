//
//  DailyGoal.swift
//  MyPomodoro
//

import Foundation
import SwiftData

@Model
final class DailyGoal {
    @Attribute(.unique) var id: UUID
    var targetMinutes: Int
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        targetMinutes: Int = AppConstants.defaultDailyGoalMinutes,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.targetMinutes = targetMinutes
        self.updatedAt = updatedAt
    }
}
