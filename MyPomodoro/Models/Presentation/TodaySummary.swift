//
//  TodaySummary.swift
//  MyPomodoro
//

import Foundation

struct TodaySummary: Identifiable, Equatable {
    let id: Date
    let totalMinutes: Int
    let completedSessionCount: Int
    let goalMinutes: Int
    let progress: Double

    init(
        id: Date = Date.startOfToday(),
        totalMinutes: Int,
        completedSessionCount: Int,
        goalMinutes: Int,
        progress: Double
    ) {
        self.id = id
        self.totalMinutes = totalMinutes
        self.completedSessionCount = completedSessionCount
        self.goalMinutes = goalMinutes
        self.progress = progress
    }
}
