//
//  QuickStartSection.swift
//  MyPomodoro
//

import SwiftUI

struct QuickStartSection: View {
    let lastSubject: Subject?
    let onStartTimer: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("빠른 시작")
                .font(.headline)
                .foregroundStyle(.secondary)

            if let lastSubject {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: lastSubject.colorHex))
                        .frame(width: 12, height: 12)
                    Text(lastSubject.name)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
            } else {
                EmptyStateView(
                    title: "오늘 첫 공부를 시작해 보세요",
                    message: "마지막 선택 과목이 없으면 Timer 탭에서 먼저 과목을 고를 수 있습니다."
                )
                .frame(minHeight: 150)
            }

            Button {
                onStartTimer()
            } label: {
                Label("타이머 시작", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
