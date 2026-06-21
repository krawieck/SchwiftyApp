//
//  Misc.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import Foundation

struct Info: Codable {
    let count: Int
    let pages: Int
    /// URL
    let next: String?
    /// URL
    let prev: String?
}

struct LocationSummary: Codable, Equatable {
    let name: String
    let url: String?
}


enum Status: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
    case genderless = "Genderless"
    case unknown = "unknown"
}
