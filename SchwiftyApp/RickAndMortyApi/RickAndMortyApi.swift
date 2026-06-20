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
    func getCharacters(with request: Character.Request) async throws -> Character.Response {
        let url = try request.url(for: Self.baseURL.appendingPathComponent("character"))
        
        let (data, _) = try await Self.urlSession.data(from: url)
        return try JSONDecoder().decode(Character.Response.self, from: data)
    }
    func getCharacters(by ids: Int...) async throws -> Character.Response {
        let request = Character.Request(ids: ids, filters: .empty())
        return try await getCharacters(with: request)
    }
    
    func getCharacters(filtered: Character.Request.Filters) async throws -> Character.Response {
        return try await getCharacters(with: .init(ids: [], filters: filtered))
    }

}

extension RickAndMortyApi {
    func getLocations(with request: Location.Request) async throws -> Location.Response {
        let url = try request.url(for: Self.baseURL.appendingPathComponent("location"))

        let (data, _) = try await Self.urlSession.data(from: url)
        return try JSONDecoder().decode(Location.Response.self, from: data)
    }
    func getLocations(by ids: Int...) async throws -> Location.Response {
        let request = Location.Request(ids: ids, filters: .empty())
        return try await getLocations(with: request)
    }

    func getLocations(filtered: Location.Request.Filters) async throws -> Location.Response {
        return try await getLocations(with: .init(ids: [], filters: filtered))
    }
}

extension RickAndMortyApi {
    func getEpisodes(with request: Episode.Request) async throws -> Episode.Response {
        let url = try request.url(for: Self.baseURL.appendingPathComponent("episode"))

        let (data, _) = try await Self.urlSession.data(from: url)
        return try JSONDecoder().decode(Episode.Response.self, from: data)
    }
    func getEpisodes(by ids: Int...) async throws -> Episode.Response {
        let request = Episode.Request(ids: ids, filters: .empty())
        return try await getEpisodes(with: request)
    }

    func getEpisodes(filtered: Episode.Request.Filters) async throws -> Episode.Response {
        return try await getEpisodes(with: .init(ids: [], filters: filtered))
    }
}
