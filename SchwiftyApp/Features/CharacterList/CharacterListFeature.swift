//
//  CharacterListFeature.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//


import Foundation
import ComposableArchitecture

@Reducer
struct CharacterList {
    @ObservableState
    struct State: Equatable {
        var fetching: Bool = false
        var fetchingError: String? = nil
        var page = 1
        var canFetchMore: Bool = true
        var characters: [Character] = []
        @Shared(.favorites) var favorites: IdentifiedArrayOf<Character> = []
        
        @Presents var characterDetails: CharacterDetailsFeature.State?
    }
    enum Action {
        case fetchCharacters
        case fetchCharactersDone(data: Character.Response)
        case fetchCharacteresFailure(String)
        case goToCharacter(character: Character)
        case characterDetails(PresentationAction<CharacterDetailsFeature.Action>)
        case scrolledToTheBottom
        case start
        case refresh
        
        case removeFromFavorites(Character)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchCharacters:
                if state.fetching || !state.canFetchMore {
                    return .none
                }
                state.fetching = true
                state.fetchingError = nil
                print("fetching page \(state.page)")
                return .run { [page = state.page] send in
                    do {
                        let response = try await RickAndMortyApi.shared.getCharacters(on: page)
                        return await send(.fetchCharactersDone(data: response))
                    } catch {
                        print("failed to fetch characters: \(error)")
                        return await send(.fetchCharacteresFailure(error.localizedDescription))
                    }

                }
            case .refresh:
                if state.fetching {
                    return .none
                }
                state.page = 1
                state.characters = []
                state.canFetchMore = true
                state.fetchingError = nil
                return .send(.fetchCharacters)
            case .fetchCharactersDone(data: let data):
                state.fetching = false
                state.page += 1
                state.characters.append(contentsOf: data.results)
                state.canFetchMore = data.info.next != nil
                return .none

            case .goToCharacter(character: let character):
                state.characterDetails = CharacterDetailsFeature.State(character: character)
                return .none
            case .characterDetails:
                return .none
            case .fetchCharacteresFailure(let message):
                state.fetching = false
                state.fetchingError = message
                return .none
            case .scrolledToTheBottom:
                return .send(.fetchCharacters)
            case .start:
                return .send(.fetchCharacters)
            case .removeFromFavorites(let character):
                state.$favorites.withLock { favorites in
                    favorites.removeAll(where: { $0.id == character.id })
                }
                return .none
            }
        }
        .ifLet(\.$characterDetails, action: \.characterDetails) {
            CharacterDetailsFeature()
        }
    }
}
    
