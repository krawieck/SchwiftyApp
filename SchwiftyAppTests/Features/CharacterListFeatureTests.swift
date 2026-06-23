//
//  CharacterListFeatureTests.swift
//  SchwiftyAppTests
//
//  Created by Filip Krawczyk on 23/06/2026.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import SchwiftyApp

@MainActor
struct CharacterListFeatureTests {

    // MARK: fetchCharacters: happy path

    @Test("Fetching characters appends results and increments the page")
    func fetchCharactersSucceeds() async {
        let api = TestRickAndMortyApi()
        let returnedCharacters = [Self.character(id: 1), Self.character(id: 2)]
        let response = Self.response(results: returnedCharacters, next: "https://next")
        api.getCharactersWith = { _ in response }

        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 2
            $0.characters = returnedCharacters
            $0.canFetchMore = true
        }
    }

    @Test("Fetch calls the API with the current page")
    func fetchCharactersUsesCurrentPage() async {
        let api = TestRickAndMortyApi()
        var capturedPage: Int? = nil
        api.getCharactersWith = { request in
            #expect(request.page != nil)
            capturedPage = request.page
            return Self.response(results: [], next: nil)
        }

        var initialState = CharacterList.State()
        initialState.page = 4

        let store = TestStore(initialState: initialState) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 5
            $0.canFetchMore = false
        }

        #expect(capturedPage == 4)
    }

    @Test(
        "canFetchMore reflects whether a next page exists",
        arguments: [true, false]
    )
    func canFetchMoreReflectsNextPage(hasNext: Bool) async {
        let api = TestRickAndMortyApi()
        let response = Self.response(
            results: [.mock],
            next: hasNext ? "https://next" : nil
        )
        api.getCharactersWith = { _ in response }

        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 2
            $0.characters = [.mock]
            $0.canFetchMore = hasNext
        }
    }

    // MARK: Pagination

    @Test("Sequential fetches advance pages and accumulate characters")
    func paginatesAcrossFetches() async {
        let api = TestRickAndMortyApi()
        let page1 = [Self.character(id: 1), Self.character(id: 2)]
        let page2 = [Self.character(id: 3), Self.character(id: 4)]
        var requestedPages: [Int] = []
        api.getCharactersWith = { request in
            #expect(request.page != nil)
            requestedPages.append(request.page!)
            switch request.page {
            case 1: return Self.response(
                results: page1,
                next: "https://next"
            )
            case 2: return Self.response(results: page2, next: nil)
            default:
                Issue.record("Unexpected page request: \(String(describing: request.page))")
                return Self.response(results: [], next: nil)
            }
        }

        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 2
            $0.characters = page1
            $0.canFetchMore = true
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 3
            $0.characters = page1 + page2
            $0.canFetchMore = false
        }

        #expect(requestedPages == [1, 2])
    }

    @Test("Fetching stops once there is no next page")
    func fetchStopsWhenExhausted() async {
        let api = TestRickAndMortyApi()
        var callCount = 0
        api.getCharactersWith = { _ in
            callCount += 1
            return Self.response(results: [.mock], next: nil)
        }

        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 2
            $0.characters = [.mock]
            $0.canFetchMore = false
        }

        await store.send(.fetchCharacters)

        #expect(callCount == 1)
    }

    // MARK: fetchCharacters: guard conditions

    @Test("Fetching while already fetching does nothing")
    func fetchIgnoredWhileFetching() async {
        var initialState = CharacterList.State()
        initialState.fetching = true

        let api = TestRickAndMortyApi()
        api.getCharactersWith = { _ in
            Issue.record("API should not be called when already fetching")
            return Self.response(results: [], next: nil)
        }

        let store = TestStore(initialState: initialState) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters)
    }

    @Test("Fetching when no more pages does nothing")
    func fetchIgnoredWhenExhausted() async {
        var initialState = CharacterList.State()
        initialState.canFetchMore = false

        let api = TestRickAndMortyApi()
        api.getCharactersWith = { _ in
            Issue.record("API should not be called when no more pages")
            return Self.response(results: [], next: nil)
        }

        let store = TestStore(initialState: initialState) {
            CharacterList()
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
        api.getCharactersWith = { _ in
            throw NSError(
                domain: "CharacterListFeatureTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: expectedMessage]
            )
        }

        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharacteresFailure) {
            $0.fetching = false
            $0.fetchingError = expectedMessage
        }
    }

    @Test("Failure leaves the page unchanged")
    func failureDoesNotAdvancePage() async {
        let api = TestRickAndMortyApi()
        let expectedMessage = "fail"
        api.getCharactersWith = { _ in
            throw NSError(
                domain: "CharacterListFeatureTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: expectedMessage]
            )
        }

        var initialState = CharacterList.State()
        initialState.page = 3

        let store = TestStore(initialState: initialState) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharacteresFailure) {
            $0.fetching = false
            $0.fetchingError = expectedMessage
        }

        #expect(store.state.page == 3)
    }

    // MARK: refresh

    @Test("Refresh resets paging state and refetches from page 1")
    func refreshResetsAndRefetches() async {
        let api = TestRickAndMortyApi()
        let response = Self.response(results: [.mock], next: "https://next")
        var capturedPage: Int? = nil
        api.getCharactersWith = { request in
            capturedPage = request.page
            return response
        }

        var initialState = CharacterList.State()
        initialState.page = 3
        initialState.characters = [Self.character(id: 99)]
        initialState.canFetchMore = false
        initialState.fetchingError = "boom"

        let store = TestStore(initialState: initialState) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.refresh) {
            $0.page = 1
            $0.characters = []
            $0.canFetchMore = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharacters) {
            $0.fetching = true
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 2
            $0.characters = [.mock]
        }

        #expect(capturedPage == 1)
    }

    @Test("Refresh while fetching does nothing")
    func refreshIgnoredWhileFetching() async {
        var initialState = CharacterList.State()
        initialState.fetching = true
        initialState.page = 5

        let api = TestRickAndMortyApi()
        api.getCharactersWith = { _ in
            Issue.record("API should not be called when refresh is guarded")
            return Self.response(results: [], next: nil)
        }

        let store = TestStore(initialState: initialState) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.refresh)
    }

    // MARK: start + scroll triggers

    @Test("Start triggers character fetching")
    func startTriggersFetch() async {
        let api = TestRickAndMortyApi()
        api.getCharactersWith = {
            _ in Self.response(results: [.mock], next: nil)
        }

        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.start)
        await store.receive(\.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 2
            $0.characters = [.mock]
            $0.canFetchMore = false
        }
    }

    @Test("Scrolling to the bottom triggers fetching")
    func scrollToBottomTriggersFetch() async {
        let api = TestRickAndMortyApi()
        api.getCharactersWith = {
            _ in Self.response(results: [.mock], next: nil)
        }

        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = api
        }

        await store.send(.scrolledToTheBottom)
        await store.receive(\.fetchCharacters) {
            $0.fetching = true
            $0.fetchingError = nil
        }
        await store.receive(\.fetchCharactersDone) {
            $0.fetching = false
            $0.page = 2
            $0.characters = [.mock]
            $0.canFetchMore = false
        }
    }

    // MARK: Navigation / presentation

    @Test("Going to a character presents the details child")
    func goToCharacterPresentsChild() async throws {
        let store = TestStore(initialState: CharacterList.State()) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = TestRickAndMortyApi()
        }

        await store.send(.goToCharacter(character: .mock)) {
            $0.characterDetails = CharacterDetailsFeature.State(character: .mock)
        }

        let presented = try #require(store.state.characterDetails)
        #expect(presented.character == .mock)
    }

    @Test("Dismissing character details clears the child state")
    func dismissClearsCharacterDetails() async {
        var initialState = CharacterList.State()
        initialState.characterDetails = CharacterDetailsFeature.State(character: .mock)

        let store = TestStore(initialState: initialState) {
            CharacterList()
        } withDependencies: {
            $0.apiClient = TestRickAndMortyApi()
        }

        await store.send(.characterDetails(.dismiss)) {
            $0.characterDetails = nil
        }
    }

    // MARK: removeFromFavorites

    @Test("Removing a favorite deletes it by id")
    func removeFromFavoritesDeletesByID() async {
        await withDependencies {
            $0.defaultFileStorage = .inMemory
        } operation: {
            let initialState = CharacterList.State()
            initialState.$favorites.withLock { favorites in
                _ = favorites.append(.mock)
            }

            let store = TestStore(initialState: initialState) {
                CharacterList()
            } withDependencies: {
                $0.apiClient = TestRickAndMortyApi()
            }

            await store.send(.removeFromFavorites(.mock)) { state in
                state.$favorites.withLock { favorites in
                    _ = favorites.remove(id: Character.mock.id)
                }
            }
            #expect(store.state.favorites.isEmpty)
        }
    }

    @Test("Removing a character that isn't a favorite is a no-op")
    func removeNonFavoriteDoesNothing() async {
        await withDependencies {
            $0.defaultFileStorage = .inMemory
        } operation: {
            let other = Self.character(id: 42)
            let initialState = CharacterList.State()
            initialState.$favorites.withLock { favorites in
                _ = favorites.append(other)
            }

            let store = TestStore(initialState: initialState) {
                CharacterList()
            } withDependencies: {
                $0.apiClient = TestRickAndMortyApi()
            }

            await store.send(.removeFromFavorites(.mock))
            #expect(store.state.favorites.elements == [other])
        }
    }

    // MARK: Helpers

    private static func response(
        results: [Character],
        next: String?
    ) -> Character.Response {
        Character.Response(
            info: Info(count: results.count, pages: 1, next: next, prev: nil),
            results: results
        )
    }

    private static func character(id: Int) -> Character {
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


private final class TestRickAndMortyApi: RickAndMortyApi {
    var getCharactersWith: (Character.Request) async throws -> Character.Response = { _ in
        Character.Response(
            info: Info(count: 0, pages: 0, next: nil, prev: nil),
            results: []
        )
    }

    override func getCharacters(with request: Character.Request) async throws -> Character.Response {
        try await getCharactersWith(request)
    }
}
