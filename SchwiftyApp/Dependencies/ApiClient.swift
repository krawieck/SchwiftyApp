//
//  ApiClient.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 22/06/2026.
//
import Dependencies

enum APIClientKey: DependencyKey {
    static let liveValue: RickAndMortyApi = .shared
    static let previewValue: RickAndMortyApi = MockRickAndMortyApi()
}

extension DependencyValues {
    var apiClient: RickAndMortyApi {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

final class MockRickAndMortyApi: RickAndMortyApi {
    private static let info = Info(count: 1, pages: 1, next: nil, prev: nil)

    override func getCharacters(with request: Character.Request) async throws -> Character.Response {
        Character.Response(info: Self.info, results: [.mock])
    }

    override func getCharacters(by ids: [Int]) async throws -> [Character] {
        ids.map { id in
            Character(
                id: id,
                name: Character.mock.name,
                status: Character.mock.status,
                species: Character.mock.species,
                type: Character.mock.type,
                gender: Character.mock.gender,
                origin: Character.mock.origin,
                location: Character.mock.location,
                image: Character.mock.image,
                episode: Character.mock.episode,
                url: Character.mock.url,
                created: Character.mock.created
            )
        }
    }

    override func getLocations(with request: Location.Request) async throws -> Location.Response {
        Location.Response(info: Self.info, results: [.mock])
    }

    override func getLocations(by ids: [Int]) async throws -> [Location] {
        ids.map { id in
            Location(
                id: id,
                name: Location.mock.name,
                type: Location.mock.type,
                dimension: Location.mock.dimension,
                residents: Location.mock.residents,
                url: Location.mock.url,
                created: Location.mock.created
            )
        }
    }

    override func getEpisodes(with request: Episode.Request) async throws -> Episode.Response {
        Episode.Response(info: Self.info, results: [.mock])
    }

    override func getEpisodes(by ids: [Int]) async throws -> [Episode] {
        ids.map { id in
            Episode(
                id: id,
                name: Episode.mock.name,
                air_date: Episode.mock.air_date,
                episode: Episode.mock.episode,
                characters: Episode.mock.characters,
                url: Episode.mock.url,
                created: Episode.mock.created
            )
        }
    }
}
