//
//  DateRange.swift
//  MyPomodoro
//

import Foundation

enum DateRange: String, Codable, CaseIterable, Sendable {
    case today
    case thisWeek

    var displayName: String {
        switch self {
        case .today: "오늘"
        case .thisWeek: "이번 주"
        }
    }
}
