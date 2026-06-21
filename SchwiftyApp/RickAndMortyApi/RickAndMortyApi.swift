//
//  RickApi.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 18/06/2026.
//

import Foundation

class RickAndMortyApi {
    static let shared = RickAndMortyApi()
    static let urlSession: URLSession = .shared
    static let baseURL: URL = URL(string: "https://rickandmortyapi.com/api")!
}

extension RickAndMortyApi {
    // FIXME: hacky solution for now. make better if time allows
    private func decodeByIds<T: Decodable>(_ data: Data, count: Int) throws -> [T] {
        let decoder = JSONDecoder()
        if count == 1 {
            return [try decoder.decode(T.self, from: data)]
        }
        return try decoder.decode([T].self, from: data)
    }
}

extension RickAndMortyApi {
    func getCharacters(with request: Character.Request) async throws -> Character.Response {
        let url = try request.url(for: Self.baseURL.appendingPathComponent("character"))
        print(url)

        let (data, _) = try await Self.urlSession.data(from: url)

        return try JSONDecoder().decode(Character.Response.self, from: data)
    }
    func getCharacters(by ids: [Int]) async throws -> [Character] {
        let request = Character.Request(ids: ids, page: nil, filters: .empty())
        let url = try request.url(for: Self.baseURL.appendingPathComponent("character"))
        let (data, _) = try await Self.urlSession.data(from: url)
        return try decodeByIds(data, count: ids.count)
    }


    func getCharacters(on page: Int? = nil, filtered: Character.Request.Filters) async throws -> Character.Response {
        return try await getCharacters(with: .init(ids: [], page: page, filters: filtered))
    }

    func getCharacters(on page: Int) async throws -> Character.Response {
        return try await getCharacters(
            with: .init(ids: [], page: page, filters: .empty())
        )
    }

}

extension RickAndMortyApi {
    func getLocations(with request: Location.Request) async throws -> Location.Response {
        let url = try request.url(for: Self.baseURL.appendingPathComponent("location"))

        let (data, _) = try await Self.urlSession.data(from: url)
        return try JSONDecoder().decode(Location.Response.self, from: data)
    }
    func getLocations(by ids: [Int]) async throws -> [Location] {
        let request = Location.Request(ids: ids, page: nil, filters: .empty())
        let url = try request.url(for: Self.baseURL.appendingPathComponent("location"))
        let (data, _) = try await Self.urlSession.data(from: url)
        return try decodeByIds(data, count: ids.count)
    }

    func getLocations(on page: Int? = nil, filtered: Location.Request.Filters) async throws -> Location.Response {
        return try await getLocations(with: .init(ids: [], page: page, filters: filtered))
    }

    func getLocations(on page: Int) async throws -> Location.Response {
        return try await getLocations(
            with: .init(ids: [], page: page, filters: .empty())
        )
    }

}

extension RickAndMortyApi {
    func getEpisodes(with request: Episode.Request) async throws -> Episode.Response {
        let url = try request.url(for: Self.baseURL.appendingPathComponent("episode"))

        let (data, _) = try await Self.urlSession.data(from: url)
        return try JSONDecoder().decode(Episode.Response.self, from: data)
    }
    func getEpisodes(by ids: [Int]) async throws -> [Episode] {
        let request = Episode.Request(ids: ids, page: nil, filters: .empty())
        let url = try request.url(for: Self.baseURL.appendingPathComponent("episode"))
        let (data, _) = try await Self.urlSession.data(from: url)
        return try decodeByIds(data, count: ids.count)
    }

    func getEpisodes(on page: Int? = nil, filtered: Episode.Request.Filters) async throws -> Episode.Response {
        return try await getEpisodes(with: .init(ids: [], page: page, filters: filtered))
    }

    func getEpisodes(on page: Int) async throws -> Episode.Response {
        return try await getEpisodes(
            with: .init(ids: [], page: page, filters: .empty())
        )
    }
}
