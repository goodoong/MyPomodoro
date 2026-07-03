//
//  AppDependencies.swift
//  MyPomodoro
//

import Foundation
import SwiftData

@MainActor
final class AppDependencies {
    let timerEngine: TimerEngineProtocol
    let sessionService: StudySessionServiceProtocol
    let subjectService: SubjectServiceProtocol
    let statisticsService: StatisticsServiceProtocol
    let settingsService: SettingsServiceProtocol

    private var homeViewModel: HomeViewModel?
    private var timerViewModel: TimerViewModel?
    private var statisticsViewModel: StatisticsViewModel?
    private var settingsViewModel: SettingsViewModel?

    init(modelContext: ModelContext) {
        let preferencesStore = UserPreferencesStore()
        self.timerEngine = TimerEngine()
        self.sessionService = StudySessionService(modelContext: modelContext)
        self.subjectService = SubjectService(modelContext: modelContext, preferencesStore: preferencesStore)
        self.statisticsService = StatisticsService(modelContext: modelContext)
        self.settingsService = SettingsService(modelContext: modelContext)
    }

    func makeHomeViewModel() -> HomeViewModel {
        if let homeViewModel {
            return homeViewModel
        }
        let vm = HomeViewModel(
            statisticsService: statisticsService,
            subjectService: subjectService
        )
        self.homeViewModel = vm
        return vm
    }

    func makeTimerViewModel() -> TimerViewModel {
        if let timerViewModel {
            return timerViewModel
        }
        let vm = TimerViewModel(
            timerEngine: timerEngine,
            sessionService: sessionService,
            subjectService: subjectService,
            settingsService: settingsService
        )
        self.timerViewModel = vm
        return vm
    }

    func makeStatisticsViewModel() -> StatisticsViewModel {
        if let statisticsViewModel {
            return statisticsViewModel
        }
        let vm = StatisticsViewModel(
            statisticsService: statisticsService,
            settingsService: settingsService
        )
        self.statisticsViewModel = vm
        return vm
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        if let settingsViewModel {
            return settingsViewModel
        }
        let vm = SettingsViewModel(
            settingsService: settingsService,
            subjectService: subjectService
        )
        self.settingsViewModel = vm
        return vm
    }
}
