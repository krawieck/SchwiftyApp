//
//  Favorites.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 21/06/2026.
//

import ComposableArchitecture
import Foundation

extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<Character>>.Default {
    static var favorites: Self {
        Self[.fileStorage(.favoritesURL), default: []]
    }
}

extension URL {
    static let favoritesURL = URL.documentsDirectory.appending(path: "favorites.json")
}

extension IdentifiedArray where Element == Character, ID == Character.ID {
    mutating func toggleFavorite(_ character: Character) {
        if self[id: character.id] != nil {
            remove(id: character.id)
        } else {
            append(character)
        }
    }
}
