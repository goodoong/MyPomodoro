//
//  HomeView.swift
//  MyPomodoro
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    let onStartTimer: () -> Void

    init(viewModel: HomeViewModel, onStartTimer: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onStartTimer = onStartTimer
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    TodaySummaryCard(summary: viewModel.todaySummary)

                    QuickStartSection(
                        lastSubject: viewModel.lastSubject,
                        onStartTimer: { viewModel.requestStartTimer(onNavigate: { _ in onStartTimer() }) }
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Home")
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                Task {
                    await viewModel.load()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let schema = Schema([Subject.self, StudySession.self, DailyGoal.self])
    let container = try! ModelContainer(
        for: schema,
        configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
    )
    let dependencies = AppDependencies(modelContext: container.mainContext)

    return HomeView(
        viewModel: dependencies.makeHomeViewModel(),
        onStartTimer: {}
    )
    .modelContainer(container)
}
