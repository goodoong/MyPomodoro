//
//  TimerView.swift
//  MyPomodoro
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @StateObject private var viewModel: TimerViewModel
    let onOpenSettings: () -> Void
    @Environment(\.scenePhase) private var scenePhase

    init(
        viewModel: TimerViewModel,
        onOpenSettings: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    TimerDisplayView(
                        mode: viewModel.mode,
                        state: viewModel.state,
                        remainingSeconds: viewModel.remainingSeconds,
                        progressFraction: viewModel.progressFraction
                    )

                    SubjectPickerView(
                        subjects: viewModel.subjects,
                        selectedSubject: viewModel.selectedSubject,
                        isDisabled: viewModel.state == .running,
                        onSelect: { viewModel.selectSubject($0) },
                        onOpenSettings: onOpenSettings
                    )

                    TimerControlBar(
                        state: viewModel.state,
                        canStart: viewModel.canStart,
                        onStart: { viewModel.start() },
                        onPause: { viewModel.pause() },
                        onResume: { viewModel.resume() },
                        onStop: { viewModel.stop() }
                    )
                }
                .padding(20)
            }
            .navigationTitle("Timer")
            .background(Color.black.ignoresSafeArea())
            .task {
                viewModel.load()
            }
            .onChange(of: scenePhase) { _, newValue in
                viewModel.onScenePhaseChange(newValue)
            }
            .alert(
                "타이머",
                isPresented: Binding(
                    get: { viewModel.alertMessage != nil },
                    set: { if $0 == false { viewModel.alertMessage = nil } }
                )
            ) {
                Button("확인", role: .cancel) {
                    viewModel.alertMessage = nil
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
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

    return TimerView(
        viewModel: dependencies.makeTimerViewModel(),
        onOpenSettings: {}
    )
    .modelContainer(container)
}
