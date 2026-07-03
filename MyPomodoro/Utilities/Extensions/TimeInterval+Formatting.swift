//
//  TimeInterval+Formatting.swift
//  MyPomodoro
//

import Foundation

extension TimeInterval {
    /// 타이머 표시용 `mm:ss` (예: 25:00, 04:59)
    var timerDisplayString: String {
        let totalSeconds = max(0, Int(self.rounded(.down)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 통계 표시용 분 단위 (예: 120분)
    var minutesDisplayString: String {
        let minutes = max(0, Int(self.rounded(.down)) / 60)
        return "\(minutes)분"
    }

    /// 분 단위 정수값
    var wholeMinutes: Int {
        max(0, Int(self.rounded(.down)) / 60)
    }
}
