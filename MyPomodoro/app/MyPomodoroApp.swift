//
//  MyPomodoroApp.swift
//  MyPomodoro
//

import SwiftUI
import SwiftData

@main
struct MyPomodoroApp: App {
    private let container: ModelContainer
    private let dependencies: AppDependencies

    init() {
        let schema = Schema([Subject.self, StudySession.self, DailyGoal.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.container = container
            self.dependencies = AppDependencies(modelContext: container.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(dependencies: dependencies)
        }
        .modelContainer(container)
    }
}
