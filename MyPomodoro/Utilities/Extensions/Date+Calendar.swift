//
//  Date+Calendar.swift
//  MyPomodoro
//

import Foundation

extension Date {
    /// 오늘 00:00 (로컬 캘린더 기준)
    static func startOfToday(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: Date())
    }

    /// 내일 00:00 — 오늘 구간의 끝(exclusive)
    static func startOfTomorrow(calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: .day, value: 1, to: startOfToday(calendar: calendar))
    }

    /// 오늘 하루 구간 [00:00, 내일 00:00)
    static func todayInterval(calendar: Calendar = .current) -> DateInterval? {
        let start = startOfToday(calendar: calendar)
        guard let end = startOfTomorrow(calendar: calendar) else { return nil }
        return DateInterval(start: start, end: end)
    }

    /// 이번 주 구간 (월요일 00:00 ~ 다음 월요일 00:00)
    static func thisWeekInterval(calendar: Calendar = .current) -> DateInterval? {
        var mondayCalendar = calendar
        mondayCalendar.firstWeekday = 2

        let now = Date()
        guard let weekStart = mondayCalendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return nil
        }
        guard let weekEnd = mondayCalendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return nil
        }
        return DateInterval(start: weekStart, end: weekEnd)
    }

    /// 주어진 `DateRange`에 해당하는 구간
    static func interval(for range: DateRange, calendar: Calendar = .current) -> DateInterval? {
        switch range {
        case .today: todayInterval(calendar: calendar)
        case .thisWeek: thisWeekInterval(calendar: calendar)
        }
    }
}
