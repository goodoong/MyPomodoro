//
//  MainTabView.swift
//  MyPomodoro
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                viewModel: dependencies.makeHomeViewModel(),
                onStartTimer: { selectedTab = .timer }
            )
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppTab.home)

            TimerView(
                viewModel: dependencies.makeTimerViewModel(),
                onOpenSettings: { selectedTab = .settings }
            )
                .tabItem { Label("Timer", systemImage: "timer") }
                .tag(AppTab.timer)

            StatisticsView(
                viewModel: dependencies.makeStatisticsViewModel(),
                onStartTimer: { selectedTab = .timer }
            )
                .tabItem { Label("Statistics", systemImage: "chart.bar.fill") }
                .tag(AppTab.statistics)

            SettingsView(viewModel: dependencies.makeSettingsViewModel())
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let schema = Schema([Subject.self, StudySession.self, DailyGoal.self])
    let container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
    let dependencies = AppDependencies(modelContext: container.mainContext)

    return MainTabView(dependencies: dependencies)
        .modelContainer(container)
}
