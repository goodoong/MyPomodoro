//
//  StatisticsServiceProtocol.swift
//  MyPomodoro
//

import Foundation

protocol StatisticsServiceProtocol {
    func todaySummary(goalMinutes: Int) throws -> TodaySummary
    func summary(for dateRange: DateRange) throws -> StatisticsSummary
    func subjectDistribution(for dateRange: DateRange) throws -> [SubjectDistributionItem]
}
