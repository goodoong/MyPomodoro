//
//  SubjectDistributionItem.swift
//  MyPomodoro
//

import Foundation

struct SubjectDistributionItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let colorHex: String
    let minutes: Int
    let percentage: Double

    init(
        id: UUID,
        name: String,
        colorHex: String,
        minutes: Int,
        percentage: Double
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.minutes = minutes
        self.percentage = percentage
    }
}
