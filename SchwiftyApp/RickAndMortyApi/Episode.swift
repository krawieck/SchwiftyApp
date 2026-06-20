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

extension Episode {
    static let mock = Episode(
        id: 1,
        name: "Pilot",
        air_date: "December 2, 2013",
        episode: "S01E01",
        characters: [1, 2, 35, 38, 62, 92, 127, 144, 158, 175, 179, 181, 239, 249, 271, 338, 394, 395, 435]
            .map { URL(string: "https://rickandmortyapi.com/api/character/\($0)")! },
        url: URL(string: "https://rickandmortyapi.com/api/episode/1")!,
        created: "2017-11-10T12:56:33.798Z"
    )
}
