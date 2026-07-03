//
//  SubjectPickerView.swift
//  MyPomodoro
//

import SwiftUI

struct SubjectPickerView: View {
    let subjects: [Subject]
    let selectedSubject: Subject?
    let isDisabled: Bool
    let onSelect: (Subject?) -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("과목")
                    .font(.headline)
                Spacer()
                Button {
                    onOpenSettings()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
            }

            if subjects.isEmpty {
                EmptyStateView(
                    title: "과목을 먼저 추가하세요",
                    message: "Settings에서 과목을 추가한 뒤 타이머를 시작할 수 있습니다.",
                    actionTitle: "Settings 열기",
                    action: onOpenSettings
                )
                .frame(minHeight: 180)
            } else {
                VStack(spacing: 8) {
                    ForEach(subjects, id: \.id) { subject in
                        Button {
                            onSelect(subject)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: subject.colorHex))
                                    .frame(width: 10, height: 10)
                                Text(subject.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedSubject?.id == subject.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.white.opacity(selectedSubject?.id == subject.id ? 0.14 : 0.06))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isDisabled)
                    }
                }
            }
        }
    }
}
