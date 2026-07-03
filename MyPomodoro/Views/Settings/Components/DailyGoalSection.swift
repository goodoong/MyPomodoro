//
//  DailyGoalSection.swift
//  MyPomodoro
//

import SwiftUI

struct DailyGoalSection: View {
    @Binding var dailyGoalMinutes: Int
    let onChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("일일 목표")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("목표 시간")
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(dailyGoalMinutes)분")
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: Binding(
                        get: { Double(dailyGoalMinutes) },
                        set: { onChange(Int($0.rounded())) }
                    ),
                    in: Double(AppConstants.dailyGoalRange.lowerBound)...Double(AppConstants.dailyGoalRange.upperBound),
                    step: 10
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }
}
