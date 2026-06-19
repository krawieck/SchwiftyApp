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
    let next: URL?
    let prev: URL?
}

struct LocationSummary: Codable {
    let name: String
    let url: URL
}


enum Status: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "Unknown"
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
    case genderless = "Genderless"
    case unknown = "Unknown"
}


