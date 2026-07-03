//
//  TimerEngineProtocol.swift
//  MyPomodoro
//

import Foundation

@MainActor
protocol TimerEngineProtocol: AnyObject {
    var mode: TimerMode { get }
    var state: TimerState { get }
    var remainingSeconds: Int { get }
    var sessionStartAt: Date? { get }
    var focusDurationSeconds: Int { get set }
    var breakDurationSeconds: Int { get set }

    var onTick: ((Int) -> Void)? { get set }
    var onFocusCompleted: (() -> Void)? { get set }
    var onBreakCompleted: (() -> Void)? { get set }

    func start(mode: TimerMode)
    func pause()
    func resume()
    func stop()
    func syncRemainingTime(now: Date)
}
