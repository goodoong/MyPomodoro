//
//  StatisticsView.swift
//  MyPomodoro
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    let onStartTimer: () -> Void

    init(viewModel: StatisticsViewModel, onStartTimer: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onStartTimer = onStartTimer
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker(
                        "기간",
                        selection: Binding(
                            get: { viewModel.dateRange },
                            set: { viewModel.setDateRange($0) }
                        )
                    ) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    PeriodSummaryView(
                        dailyMinutes: viewModel.dailyMinutes,
                        weeklyMinutes: viewModel.weeklyMinutes
                    )

                    if viewModel.isEmpty {
                        StatisticsEmptyState(onStartTimer: onStartTimer)
                    } else {
                        SubjectDistributionChart(items: viewModel.distribution)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Statistics")
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                viewModel.load()
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

    return StatisticsView(
        viewModel: dependencies.makeStatisticsViewModel(),
        onStartTimer: {}
    )
    .modelContainer(container)
}
