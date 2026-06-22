//
//  CharacterSchema.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 18/06/2026.
//

import Foundation

struct Character: Codable, Identifiable, Equatable {
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.status == rhs.status &&
        lhs.species == rhs.species &&
        lhs.type == rhs.type &&
        lhs.gender == rhs.gender &&
        lhs.origin == rhs.origin &&
        lhs.location == rhs.location &&
        lhs.image == rhs.image &&
        lhs.episode == rhs.episode &&
        lhs.url == rhs.url &&
        lhs.created == rhs.created
    }

    let id: Int
    let name: String
    let status: Status
    let species: String
    let type: String
    let gender: Gender
    let origin: LocationSummary
    let location: LocationSummary
    /// URL
    let image: String
    /// URL
    let episode: [String]
    let url: String
    let created: String
}

extension Character {
    var episodeNumbers: [Int] {
        episode.compactMap { $0.split(separator: "/").last.flatMap { Int($0) } }
    }
}

extension Character {
    struct Request: Codable {
        let ids: [Int]
        let page: Int?
        let filters: Filters
         
        struct Filters: Codable {
            let name: String?
            let status: Status?
            let species: String?
            let type: String?
            let gender: Gender?
            
            var asQueryItems: [URLQueryItem] {
                [
                    ("name", name),
                    ("status", status?.rawValue),
                    ("species", species),
                    ("type", type),
                    ("gender", gender?.rawValue),
                ].filter { $1 != nil }.compactMap { key, value in URLQueryItem(name: key, value: value) }
            }
            
            static func empty() -> Filters {
                .init(name: nil, status: nil, species: nil, type: nil, gender: nil)
            }
        }
        
        
        func url(for endpoint: URL) throws -> URL {
            let idJoined = ids.map(String.init).joined(separator: ",")
            guard var components = URLComponents(url: endpoint.appendingPathComponent(idJoined), resolvingAgainstBaseURL: false) else {
                throw URLError(.badURL)
            }
            var queryItems = filters.asQueryItems
            if let page {
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            components.queryItems = queryItems
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            return url
        }
    }
    
    
    struct Response: Codable {
        let info: Info
        let results: [Character]
    }
}

extension Character {
    static let mock = Character(
        id: 1,
        name: "Rick Sanchez",
        status: .alive,
        species: "Human",
        type: "",
        gender: .male,
        origin: LocationSummary(name: "Earth (C-137)", url: "https://rickandmortyapi.com/api/location/1"),
        location: LocationSummary(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        episode: (1...51).map { "https://rickandmortyapi.com/api/episode/\($0)" },
        url: "https://rickandmortyapi.com/api/character/1",
        created: "2017-11-04T18:48:46Z"
    )
}
