//
//  SubjectService.swift
//  MyPomodoro
//

import Foundation
import SwiftData

@MainActor
final class SubjectService: SubjectServiceProtocol {
    enum SubjectServiceError: LocalizedError {
        case invalidName
        case duplicateName
        case notFound

        var errorDescription: String? {
            switch self {
            case .invalidName:
                return "과목 이름을 입력해 주세요."
            case .duplicateName:
                return "이미 존재하는 과목입니다."
            case .notFound:
                return "과목을 찾을 수 없습니다."
            }
        }
    }

    private let modelContext: ModelContext
    private let preferencesStore: UserPreferencesStore

    init(
        modelContext: ModelContext,
        preferencesStore: UserPreferencesStore = UserPreferencesStore()
    ) {
        self.modelContext = modelContext
        self.preferencesStore = preferencesStore
    }

    func fetchAll() throws -> [Subject] {
        let descriptor = FetchDescriptor<Subject>(
            sortBy: [
                SortDescriptor(\Subject.sortOrder, order: .forward),
                SortDescriptor(\Subject.createdAt, order: .forward)
            ]
        )
        return try modelContext.fetch(descriptor).filter { $0.isDeleted == false }
    }

    func create(name: String, colorHex: String) throws -> Subject {
        let normalizedName = normalize(name)
        guard isValidName(normalizedName) else {
            throw SubjectServiceError.invalidName
        }

        guard try !hasDuplicate(name: normalizedName) else {
            throw SubjectServiceError.duplicateName
        }

        let nextSortOrder = try nextSortOrder()
        let subject = Subject(
            name: normalizedName,
            colorHex: colorHex,
            sortOrder: nextSortOrder
        )
        modelContext.insert(subject)
        try modelContext.save()
        return subject
    }

    func update(_ subject: Subject) throws {
        let normalizedName = normalize(subject.name)
        guard isValidName(normalizedName) else {
            throw SubjectServiceError.invalidName
        }

        guard try !hasDuplicate(name: normalizedName, excluding: subject.id) else {
            throw SubjectServiceError.duplicateName
        }

        subject.name = normalizedName
        try modelContext.save()
    }

    func softDelete(_ subject: Subject) throws {
        subject.isDeleted = true

        if preferencesStore.lastSelectedSubjectId == subject.id {
            preferencesStore.lastSelectedSubjectId = nil
        }

        try modelContext.save()
    }

    func selectedSubject() -> Subject? {
        guard let selectedId = preferencesStore.lastSelectedSubjectId else {
            return nil
        }

        let descriptor = FetchDescriptor<Subject>(
            sortBy: [SortDescriptor(\Subject.sortOrder, order: .forward)]
        )
        guard let subject = try? modelContext.fetch(descriptor).first(where: { $0.id == selectedId && $0.isDeleted == false }) else {
            return nil
        }
        return subject
    }

    func setSelectedSubject(id: UUID?) {
        guard let id else {
            preferencesStore.lastSelectedSubjectId = nil
            return
        }

        let descriptor = FetchDescriptor<Subject>(
            sortBy: [SortDescriptor(\Subject.sortOrder, order: .forward)]
        )
        guard let subject = try? modelContext.fetch(descriptor).first(where: { $0.id == id && $0.isDeleted == false }) else {
            preferencesStore.lastSelectedSubjectId = nil
            return
        }

        preferencesStore.lastSelectedSubjectId = subject.id
    }

    private func nextSortOrder() throws -> Int {
        let descriptor = FetchDescriptor<Subject>(
            sortBy: [SortDescriptor(\Subject.sortOrder, order: .reverse)]
        )
        let subjects = try modelContext.fetch(descriptor)
        return (subjects.first?.sortOrder ?? -1) + 1
    }

    private func hasDuplicate(name: String, excluding subjectId: UUID? = nil) throws -> Bool {
        let descriptor = FetchDescriptor<Subject>(
            sortBy: [SortDescriptor(\Subject.sortOrder, order: .forward)]
        )
        let subjects = try modelContext.fetch(descriptor)
        return subjects.contains {
            $0.isDeleted == false
                && $0.id != subjectId
                && normalize($0.name) == name
        }
    }

    private func isValidName(_ name: String) -> Bool {
        guard !name.isEmpty, name.count <= AppConstants.subjectNameMaxLength else {
            return false
        }
        return name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
