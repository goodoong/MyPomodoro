//
//  StatisticsViewModel.swift
//  MyPomodoro
//

import Combine
import Foundation

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var dateRange: DateRange = .today
    @Published var dailyMinutes = 0
    @Published var weeklyMinutes = 0
    @Published var distribution: [SubjectDistributionItem] = []
    @Published var isEmpty = true

    let statisticsService: StatisticsServiceProtocol
    let settingsService: SettingsServiceProtocol

    init(
        statisticsService: StatisticsServiceProtocol,
        settingsService: SettingsServiceProtocol
    ) {
        self.statisticsService = statisticsService
        self.settingsService = settingsService
    }

    func load() {
        do {
            let summary = try statisticsService.summary(for: dateRange)
            dailyMinutes = summary.dailyMinutes
            weeklyMinutes = summary.weeklyMinutes
            distribution = try statisticsService.subjectDistribution(for: dateRange)
            isEmpty = distribution.isEmpty
        } catch {
            dailyMinutes = 0
            weeklyMinutes = 0
            distribution = []
            isEmpty = true
        }
    }

    func setDateRange(_ newValue: DateRange) {
        guard dateRange != newValue else { return }
        dateRange = newValue
        load()
    }
}
