//
//  TimerMode.swift
//  MyPomodoro
//

import Foundation

enum TimerMode: String, Codable, CaseIterable, Sendable {
    case focus
    case `break`

    var displayName: String {
        switch self {
        case .focus: "집중"
        case .break: "휴식"
        }
    }
}
