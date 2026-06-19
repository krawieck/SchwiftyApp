//
//  CharacterSchema.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 18/06/2026.
//

import Foundation

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let status: Status
    let species: String
    let type: String
    let gender: Gender
    let origin: LocationSummary
    let location: LocationSummary
    let image: URL
    let episode: [URL]
    let url: URL
    let created: String
}

extension Character {
    struct Request: Codable {
        let ids: [Int]
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
            components.queryItems = filters.asQueryItems
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
