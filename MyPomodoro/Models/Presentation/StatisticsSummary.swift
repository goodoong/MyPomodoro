//
//  StatisticsSummary.swift
//  MyPomodoro
//

import Foundation

struct StatisticsSummary: Identifiable, Equatable {
    let id: DateRange
    let dailyMinutes: Int
    let weeklyMinutes: Int

    init(
        id: DateRange,
        dailyMinutes: Int,
        weeklyMinutes: Int
    ) {
        self.id = id
        self.dailyMinutes = dailyMinutes
        self.weeklyMinutes = weeklyMinutes
    }
}
