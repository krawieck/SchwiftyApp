//
//  CharacterDetailsFeatureTests.swift
//  SchwiftyAppTests
//
//  Created by Filip Krawczyk on 23/06/2026.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import SchwiftyApp

@MainActor
struct CharacterDetailsFeatureTests {

    // MARK: fetchEpisodes: happy path

    @Test("Fetching episodes successfully populates them and stops loading")
    func fetchEpisodesSucceeds() async {
        let api = TestRickAndMortyApi()
        let returnedEpisodes = [Episode.mock]
        api.getEpisodesByIds = { _ in returnedEpisodes }

        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchEpisodes) {
            $0.isFetchingEpisodes = true
            $0.fetchEpisodesFailMessage = nil
        }
        await store.receive(\.fetchEpisodesDone) {
            $0.isFetchingEpisodes = false
            $0.episodes = returnedEpisodes
        }
    }

    @Test("Fetch calls the API with the character's episode IDs")
    func fetchEpisodesUsesCorrectIDs() async {
        let api = TestRickAndMortyApi()
        var capturedIds: [Int] = []
        api.getEpisodesByIds = { ids in
            capturedIds.append(contentsOf: ids)
            return []
        }

        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchEpisodes) {
            $0.isFetchingEpisodes = true
            $0.fetchEpisodesFailMessage = nil
        }
        await store.receive(\.fetchEpisodesDone) {
            $0.isFetchingEpisodes = false
            $0.episodes = []
        }

        #expect(capturedIds == Character.mock.episodeNumbers)
    }

    // MARK: fetchEpisodes: guard conditions

    @Test("Fetching while already fetching does nothing")
    func fetchEpisodesIgnoredWhileFetching() async {
        var initialState = CharacterDetailsFeature.State(character: .mock)
        initialState.isFetchingEpisodes = true

        let api = TestRickAndMortyApi()
        api.getEpisodesByIds = { _ in
            Issue.record("API should not be called when already fetching")
            return []
        }

        let store = TestStore(initialState: initialState) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchEpisodes)
    }

    @Test("Fetching when episodes already loaded does nothing")
    func fetchEpisodesIgnoredWhenLoaded() async {
        var initialState = CharacterDetailsFeature.State(character: .mock)
        initialState.episodes = []

        let api = TestRickAndMortyApi()
        api.getEpisodesByIds = { _ in
            Issue.record("API should not be called when episodes are already loaded")
            return []
        }

        let store = TestStore(initialState: initialState) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchEpisodes)
    }

    // MARK: fetchEpisodes: failure path

    @Test("Fetch failure sets the error message")
    func fetchEpisodesFailureSetsMessage() async {
        let api = TestRickAndMortyApi()
        let expectedMessage = "Network exploded"
        api.getEpisodesByIds = { _ in
            throw NSError(
                domain: "CharacterDetailsFeatureTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: expectedMessage]
            )
        }

        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchEpisodes) {
            $0.isFetchingEpisodes = true
            $0.fetchEpisodesFailMessage = nil
        }
        await store.receive(\.fetchEpisodesFailure) {
            $0.isFetchingEpisodes = false
            $0.fetchEpisodesFailMessage = expectedMessage
        }
    }

    @Test("Fetch failure stops loading")
    func fetchEpisodesFailureResetsFlag() async {
        let api = TestRickAndMortyApi()
        let expectedMessage = "Network exploded"
        api.getEpisodesByIds = { _ in
            throw NSError(
                domain: "CharacterDetailsFeatureTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: expectedMessage]
            )
        }

        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchEpisodes) {
            $0.isFetchingEpisodes = true
            $0.fetchEpisodesFailMessage = nil
        }
        await store.receive(\.fetchEpisodesFailure) {
            $0.isFetchingEpisodes = false
            $0.fetchEpisodesFailMessage = expectedMessage
        }
    }

    // MARK: start

    @Test("Start triggers episode fetching")
    func startTriggersFetch() async {
        let api = TestRickAndMortyApi()
        api.getEpisodesByIds = { _ in [.mock] }

        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.start)
        await store.receive(\.fetchEpisodes) {
            $0.isFetchingEpisodes = true
            $0.fetchEpisodesFailMessage = nil
        }
        await store.receive(\.fetchEpisodesDone) {
            $0.isFetchingEpisodes = false
            $0.episodes = [.mock]
        }
    }

    // MARK: toggleFavorite

    @Test("Toggling a non-favorite adds the character")
    func toggleAddsFavorite() async {
        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = TestRickAndMortyApi()
        }

        await store.send(.toggleFavorite) { state in
            state.$favorites.withLock { favorites in favorites.append(.mock) }
        }
        #expect(store.state.isFavorite)
    }

    @Test("Toggling a favorite removes the character")
    func toggleRemovesFavorite() async {
        let initialState = CharacterDetailsFeature.State(character: .mock)
        _ = initialState.$favorites.withLock { favorites in favorites.append(.mock) }

        let store = TestStore(initialState: initialState) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = TestRickAndMortyApi()
        }

        await store.send(.toggleFavorite) { state in
            state.$favorites.withLock { favorites in
                _ = favorites.remove(id: Character.mock.id)
            }
        }
        #expect(!store.state.isFavorite)
    }

    @Test("Toggling twice returns to the original state")
    func toggleIsIdempotentInPairs() async {
        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = TestRickAndMortyApi()
        }

        await store.send(.toggleFavorite) { state in
            state.$favorites.withLock { favorites in favorites.append(.mock) }
        }
        await store.send(.toggleFavorite) { state in
            state.$favorites.withLock { favorites in
                _ = favorites.remove(id: Character.mock.id)
            }
        }
        #expect(!store.state.isFavorite)
    }

    // MARK: Navigation / presentation

    @Test("Going to episode details presents the child state")
    func goToEpisodeDetailsPresentsChild() async {
        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: .mock)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = TestRickAndMortyApi()
        }

        await store.send(.goToEpisodeDetails(.mock)) {
            $0.episodeDetails = EpisodeDetailsFeature.State(episode: .mock)
        }
    }

    @Test("Dismissing episode details clears the child state")
    func dismissClearsEpisodeDetails() async {
        var initialState = CharacterDetailsFeature.State(character: .mock)
        initialState.episodeDetails = EpisodeDetailsFeature.State(episode: .mock)

        let store = TestStore(initialState: initialState) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = TestRickAndMortyApi()
        }

        await store.send(.episodeDetails(.dismiss)) {
            $0.episodeDetails = nil
        }
    }

    @Test("Episode details actions route to the child reducer")
    func episodeDetailsActionRoutesToChild() async {
        let api = TestRickAndMortyApi()
        api.getCharactersByIds = { _ in [.mock] }

        var initialState = CharacterDetailsFeature.State(character: .mock)
        initialState.episodeDetails = EpisodeDetailsFeature.State(episode: .mock)

        let store = TestStore(initialState: initialState) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.episodeDetails(.presented(.fetchCharacters))) {
            $0.episodeDetails?.isFetchingCharacters = true
            $0.episodeDetails?.fetchCharactersFailMessage = nil
        }
        await store.receive(\.episodeDetails.presented.fetchCharactersDone) {
            $0.episodeDetails?.isFetchingCharacters = false
            $0.episodeDetails?.characters = [.mock]
        }
    }

    // MARK: Derived state

    @Test(
        "isFavorite reflects the favorites collection",
        arguments: [true, false]
    )
    func isFavoriteReflectsFavorites(characterIsInFavorites: Bool) {
        withDependencies {
            $0.defaultFileStorage = .inMemory
        } operation: {
            let state = CharacterDetailsFeature.State(character: .mock)
            if characterIsInFavorites {
                _ = state.$favorites.withLock { favorites in favorites.append(.mock) }
            }
            #expect(state.isFavorite == characterIsInFavorites)
        }
    }
}


private final class TestRickAndMortyApi: RickAndMortyApi {
    var getEpisodesByIds: ([Int]) async throws -> [Episode] = { _ in [] }
    var getCharactersByIds: ([Int]) async throws -> [Character] = { _ in [] }

    override func getEpisodes(by ids: [Int]) async throws -> [Episode] {
        try await getEpisodesByIds(ids)
    }

    override func getCharacters(by ids: [Int]) async throws -> [Character] {
        try await getCharactersByIds(ids)
    }
}
