//
//  StatisticsService.swift
//  MyPomodoro
//

import Foundation
import SwiftData

@MainActor
final class StatisticsService: StatisticsServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func todaySummary(goalMinutes: Int) throws -> TodaySummary {
        let sessions = try fetchSessions(in: Date.todayInterval())
        let completedSessions = sessions.filter { $0.isCompleted }
        let totalSeconds = completedSessions.reduce(0) { $0 + $1.durationSeconds }
        let totalMinutes = totalSeconds / 60
        let effectiveGoalMinutes = try fetchDailyGoal()?.targetMinutes ?? goalMinutes
        let progress = effectiveGoalMinutes > 0 ? Double(totalMinutes) / Double(effectiveGoalMinutes) : 0

        return TodaySummary(
            totalMinutes: totalMinutes,
            completedSessionCount: completedSessions.count,
            goalMinutes: effectiveGoalMinutes,
            progress: progress
        )
    }

    func summary(for dateRange: DateRange) throws -> StatisticsSummary {
        _ = dateRange

        let todaySessions = try fetchSessions(in: Date.todayInterval())
        let weekSessions = try fetchSessions(in: Date.thisWeekInterval())

        let todayMinutes = todaySessions.reduce(0) { $0 + $1.durationSeconds } / 60
        let weekMinutes = weekSessions.reduce(0) { $0 + $1.durationSeconds } / 60

        return StatisticsSummary(
            id: dateRange,
            dailyMinutes: todayMinutes,
            weeklyMinutes: weekMinutes
        )
    }

    func subjectDistribution(for dateRange: DateRange) throws -> [SubjectDistributionItem] {
        let interval = interval(for: dateRange)
        let sessions = try fetchSessions(in: interval)
        guard sessions.isEmpty == false else {
            return []
        }

        let subjects = try fetchSubjects()
        let subjectLookup = Dictionary(uniqueKeysWithValues: subjects.map { ($0.id, $0) })
        let unknownSubjectID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        var groupedSeconds: [UUID: Int] = [:]
        var metadata: [UUID: (name: String, colorHex: String)] = [:]

        for session in sessions {
            let subject = subjectLookup[session.subjectId]
            let key: UUID

            if let subject, subject.isDeleted == false {
                key = subject.id
                metadata[key] = (name: subject.name, colorHex: subject.colorHex)
            } else {
                key = unknownSubjectID
                metadata[key] = (name: "알 수 없는 과목", colorHex: "#808080")
            }

            groupedSeconds[key, default: 0] += session.durationSeconds
        }

        let totalSeconds = groupedSeconds.values.reduce(0, +)
        guard totalSeconds > 0 else {
            return []
        }

        return groupedSeconds
            .map { id, seconds in
                let info = metadata[id] ?? (name: "알 수 없는 과목", colorHex: "#808080")
                return SubjectDistributionItem(
                    id: id,
                    name: info.name,
                    colorHex: info.colorHex,
                    minutes: seconds / 60,
                    percentage: Double(seconds) / Double(totalSeconds) * 100
                )
            }
            .sorted { lhs, rhs in
                if lhs.minutes == rhs.minutes {
                    return lhs.name < rhs.name
                }
                return lhs.minutes > rhs.minutes
            }
    }

    private func fetchSessions(in interval: DateInterval?) throws -> [StudySession] {
        guard let interval else { return [] }

        let descriptor = FetchDescriptor<StudySession>(
            sortBy: [SortDescriptor(\StudySession.startedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).filter {
            interval.contains($0.startedAt)
        }
    }

    private func fetchSubjects() throws -> [Subject] {
        let descriptor = FetchDescriptor<Subject>(
            sortBy: [SortDescriptor(\Subject.sortOrder, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func fetchDailyGoal() throws -> DailyGoal? {
        let descriptor = FetchDescriptor<DailyGoal>(
            sortBy: [SortDescriptor(\DailyGoal.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).first
    }

    private func interval(for dateRange: DateRange) -> DateInterval? {
        switch dateRange {
        case .today:
            return Date.todayInterval()
        case .thisWeek:
            return Date.thisWeekInterval()
        }
    }
}
