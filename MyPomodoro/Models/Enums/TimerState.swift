//
//  TimerState.swift
//  MyPomodoro
//

import Foundation

enum TimerState: String, Codable, CaseIterable, Sendable {
    case idle
    case running
    case paused
}
