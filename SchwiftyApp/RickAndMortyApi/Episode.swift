//
//  Episode.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 18/06/2026.
//

import Foundation

struct Episode: Codable, Identifiable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [URL]
    let url: URL
    let created: String
}

extension Episode {
    struct Request: Codable {
        let ids: [Int]
        let filters: Filters

        struct Filters: Codable {
            /// filter by the given name
            let name: String?
            /// filter by the given episode code
            let episode: String?

            var asQueryItems: [URLQueryItem] {
                [
                    ("name", name),
                    ("episode", episode),
                ].filter { $1 != nil }.compactMap { key, value in URLQueryItem(name: key, value: value) }
            }

            static func empty() -> Filters {
                .init(name: nil, episode: nil)
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
        let results: [Episode]
    }
}
