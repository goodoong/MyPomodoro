//
//  SubjectManagementSection.swift
//  MyPomodoro
//

import SwiftUI

struct SubjectManagementSection: View {
    let subjects: [Subject]
    let onAdd: () -> Void
    let onEdit: (Subject) -> Void
    let onDelete: (Subject) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("과목 관리")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    onAdd()
                } label: {
                    Label("추가", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }

            VStack(spacing: 0) {
                if subjects.isEmpty {
                    ContentUnavailableView(
                        "과목이 없습니다",
                        systemImage: "square.grid.2x2",
                        description: Text("과목을 먼저 추가해 주세요.")
                    )
                    .padding(20)
                } else {
                    ForEach(Array(subjects.enumerated()), id: \.element.id) { index, subject in
                        subjectRow(subject)

                        if index < subjects.count - 1 {
                            Divider()
                                .overlay(Color.white.opacity(0.08))
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }

    private func subjectRow(_ subject: Subject) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: subject.colorHex))
                .frame(width: 12, height: 12)

            Text(subject.name)
                .foregroundStyle(.white)

            Spacer()

            Button {
                onEdit(subject)
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)

            Button(role: .destructive) {
                onDelete(subject)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
    }
}
