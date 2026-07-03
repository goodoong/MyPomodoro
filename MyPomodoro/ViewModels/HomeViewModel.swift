//
//  HomeViewModel.swift
//  MyPomodoro
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todaySummary = TodaySummary(
        totalMinutes: 0,
        completedSessionCount: 0,
        goalMinutes: AppConstants.defaultDailyGoalMinutes,
        progress: 0
    )
    @Published var lastSubject: Subject?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let statisticsService: StatisticsServiceProtocol
    let subjectService: SubjectServiceProtocol

    init(
        statisticsService: StatisticsServiceProtocol,
        subjectService: SubjectServiceProtocol
    ) {
        self.statisticsService = statisticsService
        self.subjectService = subjectService
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            todaySummary = try statisticsService.todaySummary(goalMinutes: AppConstants.defaultDailyGoalMinutes)
            lastSubject = subjectService.selectedSubject()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            todaySummary = TodaySummary(
                totalMinutes: 0,
                completedSessionCount: 0,
                goalMinutes: AppConstants.defaultDailyGoalMinutes,
                progress: 0
            )
            lastSubject = subjectService.selectedSubject()
        }
    }

    func requestStartTimer(onNavigate: (AppTab) -> Void) {
        onNavigate(.timer)
    }
}
