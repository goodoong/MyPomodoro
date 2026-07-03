//
//  ExtensionsPreview.swift
//  MyPomodoro
//
//  Phase 0-3: Date · TimeInterval extension 검증용 Preview
//

import SwiftUI

private struct ExtensionsPreview: View {
    private let focusDuration = TimeInterval(AppConstants.defaultFocusDurationSeconds)
    private let today = Date.todayInterval()
    private let thisWeek = Date.thisWeekInterval()

    var body: some View {
        List {
            Section("TimeInterval") {
                LabeledContent("25분 타이머", value: focusDuration.timerDisplayString)
                LabeledContent("25분 통계", value: focusDuration.minutesDisplayString)
            }

            Section("오늘 DateInterval") {
                if let today {
                    LabeledContent("시작", value: today.start.formatted())
                    LabeledContent("끝", value: today.end.formatted())
                } else {
                    Text("계산 실패")
                }
            }

            Section("이번 주 DateInterval (월~일)") {
                if let thisWeek {
                    LabeledContent("시작", value: thisWeek.start.formatted())
                    LabeledContent("끝", value: thisWeek.end.formatted())
                } else {
                    Text("계산 실패")
                }
            }
        }
        .navigationTitle("Extensions Preview")
    }
}

#Preview {
    NavigationStack {
        ExtensionsPreview()
    }
    .preferredColorScheme(.dark)
}
