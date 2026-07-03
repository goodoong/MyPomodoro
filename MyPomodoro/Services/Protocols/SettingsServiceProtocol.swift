//
//  SettingsServiceProtocol.swift
//  MyPomodoro
//

import Foundation

protocol SettingsServiceProtocol {
    var focusDuration: Int { get set }
    var breakDuration: Int { get set }
    var dailyGoalMinutes: Int { get set }
}
