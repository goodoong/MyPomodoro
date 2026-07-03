//
//  StudySession.swift
//  MyPomodoro
//

import Foundation
import SwiftData

@Model
final class StudySession {
    @Attribute(.unique) var id: UUID
    var subjectId: UUID
    var startedAt: Date
    var endedAt: Date
    var durationSeconds: Int
    var isCompleted: Bool
    var createdAt: Date

    var subject: Subject?

    init(
        id: UUID = UUID(),
        subjectId: UUID,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: Int,
        isCompleted: Bool = true,
        createdAt: Date = Date(),
        subject: Subject? = nil
    ) {
        self.id = id
        self.subjectId = subjectId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.subject = subject
    }
}
