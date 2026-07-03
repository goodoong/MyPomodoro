//
//  TimerDisplayView.swift
//  MyPomodoro
//

import SwiftUI

struct TimerDisplayView: View {
    let mode: TimerMode
    let state: TimerState
    let remainingSeconds: Int
    let progressFraction: Double

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(
                        mode == .focus ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.2), value: progressFraction)

                VStack(spacing: 8) {
                    Text(mode.displayName)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(TimeInterval(remainingSeconds).timerDisplayString)
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("분:초")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
            }
            .frame(width: ringSize, height: ringSize)

            Text(stateText)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var ringSize: CGFloat {
        220
    }

    private var stateText: String {
        switch state {
        case .idle:
            return "대기 중"
        case .running:
            return "진행 중"
        case .paused:
            return "일시정지"
        }
    }
}
