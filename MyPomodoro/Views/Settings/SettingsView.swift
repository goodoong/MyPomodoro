//
//  SettingsView.swift
//  MyPomodoro
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var isPresentingSubjectEditor = false
    @State private var subjectNameDraft = ""
    @State private var subjectColorHexDraft = SubjectEditPalette.defaultHex

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TimerDurationSection(
                        focusMinutes: $viewModel.focusMinutes,
                        breakMinutes: $viewModel.breakMinutes,
                        onFocusChange: { viewModel.updateFocusMinutes($0) },
                        onBreakChange: { viewModel.updateBreakMinutes($0) }
                    )

                    DailyGoalSection(
                        dailyGoalMinutes: $viewModel.dailyGoalMinutes,
                        onChange: { viewModel.updateDailyGoal($0) }
                    )

                    SubjectManagementSection(
                        subjects: viewModel.subjects,
                        onAdd: presentAddSubject,
                        onEdit: { presentEditSubject($0) },
                        onDelete: { viewModel.deleteSubject($0) }
                    )

                    appInfoSection
                }
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Settings")
            #if os(iOS) || os(tvOS) || os(visionOS)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
            .task {
                viewModel.load()
            }
            .alert(
                "설정 오류",
                isPresented: Binding(
                    get: { viewModel.validationError != nil },
                    set: { if $0 == false { viewModel.validationError = nil } }
                )
            ) {
                Button("확인", role: .cancel) {
                    viewModel.validationError = nil
                }
            } message: {
                Text(viewModel.validationError ?? "")
            }
            .sheet(isPresented: $isPresentingSubjectEditor, onDismiss: {
                viewModel.editingSubject = nil
                subjectNameDraft = ""
                subjectColorHexDraft = SubjectEditPalette.defaultHex
            }) {
                SubjectEditSheet(
                    title: viewModel.editingSubject == nil ? "과목 추가" : "과목 수정",
                    name: $subjectNameDraft,
                    colorHex: $subjectColorHexDraft,
                    validationError: viewModel.validationError,
                    onSave: saveSubject,
                    onCancel: {
                        isPresentingSubjectEditor = false
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
    }

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("앱 정보")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                Text("버전")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.white)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func presentAddSubject() {
        viewModel.editingSubject = nil
        subjectNameDraft = ""
        subjectColorHexDraft = SubjectEditPalette.defaultHex
        isPresentingSubjectEditor = true
    }

    private func presentEditSubject(_ subject: Subject) {
        viewModel.editingSubject = subject
        subjectNameDraft = subject.name
        subjectColorHexDraft = subject.colorHex
        isPresentingSubjectEditor = true
    }

    private func saveSubject() {
        if let editingSubject = viewModel.editingSubject {
            viewModel.updateSubject(editingSubject, name: subjectNameDraft, colorHex: subjectColorHexDraft)
        } else {
            viewModel.addSubject(name: subjectNameDraft, colorHex: subjectColorHexDraft)
        }

        if viewModel.validationError == nil {
            isPresentingSubjectEditor = false
        }
    }
}

private enum SubjectEditPalette {
    static let defaultHex = "#FF6B6B"
}

#Preview {
    let schema = Schema([Subject.self, StudySession.self, DailyGoal.self])
    let container = try! ModelContainer(
        for: schema,
        configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
    )
    let dependencies = AppDependencies(modelContext: container.mainContext)

    return SettingsView(viewModel: dependencies.makeSettingsViewModel())
        .modelContainer(container)
}
