//
//  StudySessionServiceProtocol.swift
//  MyPomodoro
//

import Foundation

protocol StudySessionServiceProtocol {
    func saveCompleted(
        subjectId: UUID,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: Int
    ) throws

    func fetchSessions(in interval: DateInterval) throws -> [StudySession]
    func fetchTodaySessions() throws -> [StudySession]
}
