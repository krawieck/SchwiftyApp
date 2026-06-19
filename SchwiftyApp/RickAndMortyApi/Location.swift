//
//  Location.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 18/06/2026.
//

import Foundation

struct Location: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [URL]
    let url: URL
    let created: String
}

extension Location {
    struct Request: Codable {
        let ids: [Int]
        let filters: Filters

        struct Filters: Codable {
            let name: String?
            let type: String?
            let dimension: String?

            var asQueryItems: [URLQueryItem] {
                [
                    ("name", name),
                    ("type", type),
                    ("dimension", dimension),
                ].filter { $1 != nil }.compactMap { key, value in URLQueryItem(name: key, value: value) }
            }

            static func empty() -> Filters {
                .init(name: nil, type: nil, dimension: nil)
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
        let results: [Location]
    }
}
