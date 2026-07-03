//
//  TodaySummaryCard.swift
//  MyPomodoro
//

import SwiftUI

struct TodaySummaryCard: View {
    let summary: TodaySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("오늘")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(summary.totalMinutes)분")
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("세션 \(summary.completedSessionCount)")
                        .foregroundStyle(.secondary)
                    Text("\(Int((summary.progress * 100).rounded()))%")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }

            ProgressView(value: min(summary.progress, 1))
                .tint(.green)

            Text("목표 \(summary.goalMinutes)분")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}
