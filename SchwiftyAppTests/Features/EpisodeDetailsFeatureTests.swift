//
//  EpisodeDetailsFeatureTests.swift
//  SchwiftyAppTests
//
//  Created by Filip Krawczyk on 23/06/2026.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import SchwiftyApp

@MainActor
struct EpisodeDetailsFeatureTests {
    // MARK: fetchCharacters: happy path

    @Test("Fetching characters populates them and stops loading")
    func fetchCharactersSucceeds() async {
        let api = TestRickAndMortyApi()
        let returnedCharacters = [Character.mock]
        api.getCharactersByIds = { _ in returnedCharacters }

        let store = TestStore(
            initialState: EpisodeDetailsFeature.State(episode: .mock)
        ) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.isFetchingCharacters = true
            $0.fetchCharactersFailMessage = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.isFetchingCharacters = false
            $0.characters = returnedCharacters
        }
    }

    // MARK: ID parsing

    @Test("Fetch extracts character IDs from the episode's character URLs")
    func fetchParsesCharacterIDsFromURLs() async {
        let api = TestRickAndMortyApi()
        var capturedIds: [Int] = []
        api.getCharactersByIds = { ids in
            capturedIds.append(contentsOf: ids)
            return []
        }

        let episode = Self.episode(withCharacterURLs: [
            "https://rickandmortyapi.com/api/character/1",
            "https://rickandmortyapi.com/api/character/42",
        ])

        let store = TestStore(
            initialState: EpisodeDetailsFeature.State(episode: episode)
        ) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.isFetchingCharacters = true
            $0.fetchCharactersFailMessage = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.isFetchingCharacters = false
            $0.characters = []
        }

        #expect(capturedIds == [1, 42])
    }

    @Test(
        "ID parsing handles edge cases",
        arguments: [
            (
                "trailing slash is tolerated because split omits empty subsequences",
                ["https://rickandmortyapi.com/api/character/5/"],
                [5]
            ),
            (
                "malformed and empty URLs are skipped, valid IDs survive",
                [
                    "https://rickandmortyapi.com/api/character/1",
                    "https://rickandmortyapi.com/api/character/abc",
                    "",
                    "https://rickandmortyapi.com/api/character/7",
                ],
                [1, 7]
            ),
            (
                "empty character list yields no IDs",
                [String](),
                [Int]()
            ),
        ]
    )
    func parsesIDEdgeCases(
        name: String,
        urls: [String],
        expectedIds: [Int]
    ) async {
        let api = TestRickAndMortyApi()
        var capturedIds: [Int] = []
        api.getCharactersByIds = { ids in
            capturedIds.append(contentsOf: ids)
            return []
        }

        let episode = Self.episode(withCharacterURLs: urls)

        let store = TestStore(
            initialState: EpisodeDetailsFeature.State(episode: episode)
        ) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.isFetchingCharacters = true
            $0.fetchCharactersFailMessage = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.isFetchingCharacters = false
            $0.characters = []
        }

        #expect(capturedIds == expectedIds, "case: \(name)")
    }

    // MARK: fetchCharacters: guard conditions

    @Test("Fetching while already fetching does nothing")
    func fetchIgnoredWhileFetching() async {
        var initialState = EpisodeDetailsFeature.State(episode: .mock)
        initialState.isFetchingCharacters = true

        let api = TestRickAndMortyApi()
        api.getCharactersByIds = { _ in
            Issue.record("API should not be called when already fetching")
            return []
        }

        let store = TestStore(initialState: initialState) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters)
    }

    @Test(
        "Fetching when characters already loaded does nothing",
        arguments: [
            [Character.mock],
            [Character](),
        ]
    )
    func fetchIgnoredWhenLoaded(loadedCharacters: [Character]) async {
        var initialState = EpisodeDetailsFeature.State(episode: .mock)
        initialState.characters = loadedCharacters

        let api = TestRickAndMortyApi()
        api.getCharactersByIds = { _ in
            Issue.record("API should not be called when characters are already loaded")
            return []
        }

        let store = TestStore(initialState: initialState) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters)
    }

    // MARK: fetchCharacters: failure path

    @Test("Fetch failure sets the error and stops loading")
    func fetchCharactersFailure() async {
        let api = TestRickAndMortyApi()
        let expectedMessage = "Network exploded"
        api.getCharactersByIds = { _ in
            throw NSError(
                domain: "EpisodeDetailsFeatureTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: expectedMessage]
            )
        }

        let store = TestStore(
            initialState: EpisodeDetailsFeature.State(episode: .mock)
        ) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.isFetchingCharacters = true
            $0.fetchCharactersFailMessage = nil
        }
        await store.receive(\.fetchCharactersFailure) {
            $0.isFetchingCharacters = false
            $0.fetchCharactersFailMessage = expectedMessage
        }
    }

    // MARK: start

    @Test("Start triggers character fetching")
    func startTriggersFetch() async {
        let api = TestRickAndMortyApi()
        api.getCharactersByIds = { _ in [.mock] }

        let store = TestStore(
            initialState: EpisodeDetailsFeature.State(episode: .mock)
        ) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.start)
        await store.receive(\.fetchCharacters) {
            $0.isFetchingCharacters = true
            $0.fetchCharactersFailMessage = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.isFetchingCharacters = false
            $0.characters = [.mock]
        }
    }

    // MARK: Test helpers

    private static func episode(withCharacterURLs urls: [String]) -> Episode {
        Episode(
            id: Episode.mock.id,
            name: Episode.mock.name,
            air_date: Episode.mock.air_date,
            episode: Episode.mock.episode,
            characters: urls,
            url: Episode.mock.url,
            created: Episode.mock.created
        )
    }
}


private final class TestRickAndMortyApi: RickAndMortyApi {
    var getCharactersByIds: ([Int]) async throws -> [Character] = { _ in [] }

    override func getCharacters(by ids: [Int]) async throws -> [Character] {
        try await getCharactersByIds(ids)
    }
}
