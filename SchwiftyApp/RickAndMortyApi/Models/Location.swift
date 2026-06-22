//
//  Location.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 18/06/2026.
//

import Foundation

struct Location: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    /// URL
    let residents: [String]
    /// URL
    let url: String
    let created: String
}

extension Location {
    struct Request: Codable {
        let ids: [Int]
        let page: Int?
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
        let results: [Location]
    }
}

extension Location {
    static let mock = Location(
        id: 1,
        name: "Earth (C-137)",
        type: "Planet",
        dimension: "Dimension C-137",
        residents: [38, 45, 71, 82, 83, 92, 112, 114, 116, 117, 120, 127, 155, 169, 175, 179, 186, 201, 216, 239, 271, 302, 303, 338, 343, 356, 394]
            .map { "https://rickandmortyapi.com/api/character/\($0)" },
        url: "https://rickandmortyapi.com/api/location/1",
        created: "2017-11-10T12:42:04.162Z"
    )
}
