//
//  SubjectServiceProtocol.swift
//  MyPomodoro
//

import Foundation

protocol SubjectServiceProtocol {
    func fetchAll() throws -> [Subject]
    func create(name: String, colorHex: String) throws -> Subject
    func update(_ subject: Subject) throws
    func softDelete(_ subject: Subject) throws
    func selectedSubject() -> Subject?
    func setSelectedSubject(id: UUID?)
}
