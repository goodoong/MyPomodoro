//
//  Subject.swift
//  MyPomodoro
//

import Foundation
import SwiftData

@Model
final class Subject {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date
    var sortOrder: Int
    var isDeleted: Bool

    @Relationship(deleteRule: .nullify, inverse: \StudySession.subject)
    var sessions: [StudySession]?

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        createdAt: Date = Date(),
        sortOrder: Int = 0,
        isDeleted: Bool = false,
        sessions: [StudySession]? = nil
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.sortOrder = sortOrder
        self.isDeleted = isDeleted
        self.sessions = sessions
    }
}
