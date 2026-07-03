//
//  UserPreferencesStore.swift
//  MyPomodoro
//

import Foundation

final class UserPreferencesStore {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private enum Key {
        static let lastSelectedSubjectId = "lastSelectedSubjectId"
    }

    init(
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    var lastSelectedSubjectId: UUID? {
        get {
            guard let data = defaults.data(forKey: Key.lastSelectedSubjectId) else {
                return nil
            }
            return try? decoder.decode(UUID.self, from: data)
        }
        set {
            guard let newValue else {
                defaults.removeObject(forKey: Key.lastSelectedSubjectId)
                return
            }

            guard let data = try? encoder.encode(newValue) else {
                return
            }

            defaults.set(data, forKey: Key.lastSelectedSubjectId)
        }
    }
}
