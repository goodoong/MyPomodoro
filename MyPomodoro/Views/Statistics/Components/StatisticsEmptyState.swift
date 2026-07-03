//
//  StatisticsEmptyState.swift
//  MyPomodoro
//

import SwiftUI

struct StatisticsEmptyState: View {
    let onStartTimer: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)

            Text("아직 기록이 없습니다")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("타이머를 시작해서 첫 세션을 저장하면 통계가 여기에 표시됩니다.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                onStartTimer()
            } label: {
                Label("Timer 열기", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}
