//
//  StudySessionService.swift
//  MyPomodoro
//

import Foundation
import CryptoKit
import SwiftData

@MainActor
final class StudySessionService: StudySessionServiceProtocol {
    enum StudySessionServiceError: LocalizedError {
        case invalidDateRange
        case belowMinimumDuration

        var errorDescription: String? {
            switch self {
            case .invalidDateRange:
                return "종료 시각은 시작 시각보다 이후여야 합니다."
            case .belowMinimumDuration:
                return "1분 미만의 세션은 저장하지 않습니다."
            }
        }
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveCompleted(
        subjectId: UUID,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: Int
    ) throws {
        guard endedAt >= startedAt else {
            throw StudySessionServiceError.invalidDateRange
        }

        guard durationSeconds >= AppConstants.minimumSessionDurationSeconds else {
            throw StudySessionServiceError.belowMinimumDuration
        }

        let sessionID = makeStableSessionID(
            subjectId: subjectId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds
        )

        let descriptor = FetchDescriptor<StudySession>(
            sortBy: [SortDescriptor(\StudySession.createdAt, order: .reverse)]
        )
        let existingSessions = try modelContext.fetch(descriptor)
        if let existingSession = existingSessions.first(where: { $0.id == sessionID }) {
            existingSession.subjectId = subjectId
            existingSession.startedAt = startedAt
            existingSession.endedAt = endedAt
            existingSession.durationSeconds = durationSeconds
            existingSession.isCompleted = true
        } else {
            modelContext.insert(
                StudySession(
                    id: sessionID,
                    subjectId: subjectId,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    durationSeconds: durationSeconds,
                    isCompleted: true,
                    createdAt: Date()
                )
            )
        }

        try modelContext.save()
    }

    func fetchSessions(in interval: DateInterval) throws -> [StudySession] {
        let descriptor = FetchDescriptor<StudySession>(
            sortBy: [SortDescriptor(\StudySession.startedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).filter {
            interval.contains($0.startedAt)
        }
    }

    func fetchTodaySessions() throws -> [StudySession] {
        guard let interval = Date.todayInterval() else {
            return []
        }
        return try fetchSessions(in: interval)
    }

    private func makeStableSessionID(
        subjectId: UUID,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: Int
    ) -> UUID {
        let seed = makeSeed(
            subjectId: subjectId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds
        )
        let digest = SHA256.hash(data: Data(seed.utf8))
        let hex = digest.prefix(16).map { String(format: "%02x", $0) }.joined()
        let uuidString = makeUUIDString(from: hex)
        return UUID(uuidString: uuidString) ?? UUID()
    }

    private func makeSeed(
        subjectId: UUID,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: Int
    ) -> String {
        [
            subjectId.uuidString,
            String(startedAt.timeIntervalSinceReferenceDate),
            String(endedAt.timeIntervalSinceReferenceDate),
            String(durationSeconds)
        ]
        .joined(separator: "|")
    }

    private func makeUUIDString(from hex: String) -> String {
        let part1 = String(hex.prefix(8))
        let part2 = String(hex.dropFirst(8).prefix(4))
        let part3 = String(hex.dropFirst(12).prefix(4))
        let part4 = String(hex.dropFirst(16).prefix(4))
        let part5 = String(hex.dropFirst(20).prefix(12))
        return "\(part1)-\(part2)-\(part3)-\(part4)-\(part5)"
    }
}
