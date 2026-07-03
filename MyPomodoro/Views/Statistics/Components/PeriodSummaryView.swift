//
//  PeriodSummaryView.swift
//  MyPomodoro
//

import SwiftUI

struct PeriodSummaryView: View {
    let dailyMinutes: Int
    let weeklyMinutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("기간 요약")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                MetricSummaryCard(
                    title: "오늘",
                    value: "\(dailyMinutes)분"
                )

                MetricSummaryCard(
                    title: "이번 주",
                    value: "\(weeklyMinutes)분"
                )
            }
        }
    }
}

private struct MetricSummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}
