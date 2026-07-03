//
//  TimerDurationSection.swift
//  MyPomodoro
//

import SwiftUI

struct TimerDurationSection: View {
    @Binding var focusMinutes: Int
    @Binding var breakMinutes: Int
    let onFocusChange: (Int) -> Void
    let onBreakChange: (Int) -> Void

    var body: some View {
        settingsCard(title: "타이머") {
            settingRow(
                title: "집중 시간",
                value: focusMinutes,
                range: AppConstants.focusDurationRange,
                suffix: "분",
                onChange: onFocusChange
            )

            Divider()
                .overlay(Color.white.opacity(0.08))

            settingRow(
                title: "휴식 시간",
                value: breakMinutes,
                range: AppConstants.breakDurationRange,
                suffix: "분",
                onChange: onBreakChange
            )
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }

    @ViewBuilder
    private func settingRow(
        title: String,
        value: Int,
        range: ClosedRange<Int>,
        suffix: String,
        onChange: @escaping (Int) -> Void
    ) -> some View {
        HStack(spacing: 16) {
            Text(title)
                .foregroundStyle(.white)

            Spacer()

            Text("\(value)\(suffix)")
                .font(.body)
                .foregroundStyle(.secondary)

            Stepper(
                "\(value)\(suffix)",
                value: Binding(
                    get: { value },
                    set: { onChange($0) }
                ),
                in: range
            )
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
