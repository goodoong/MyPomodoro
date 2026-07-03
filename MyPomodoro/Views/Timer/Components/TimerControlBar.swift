//
//  TimerControlBar.swift
//  MyPomodoro
//

import SwiftUI

struct TimerControlBar: View {
    let state: TimerState
    let canStart: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            switch state {
            case .idle:
                controlButton("시작", systemImage: "play.fill", action: onStart)
                    .disabled(canStart == false)
            case .running:
                controlButton("일시정지", systemImage: "pause.fill", action: onPause)
                controlButton("중단", systemImage: "stop.fill", action: onStop, isDestructive: true)
            case .paused:
                controlButton("재개", systemImage: "play.fill", action: onResume)
                controlButton("중단", systemImage: "stop.fill", action: onStop, isDestructive: true)
            }
        }
    }

    private func controlButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void,
        isDestructive: Bool = false
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(isDestructive ? .red : Color.accentColor)
    }
}
