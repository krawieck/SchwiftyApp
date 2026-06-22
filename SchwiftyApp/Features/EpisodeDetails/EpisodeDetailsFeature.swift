//
//  EpisodeFeature.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 21/06/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct EpisodeDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let episode: Episode
        var characters: [Character]? = nil
        var fetchCharactersFailMessage: String? = nil
        var isFetchingCharacters = false
    }
    enum Action {
        case fetchCharacters
        case fetchCharactersDone([Character])
        case fetchCharactersFailure(String)
        case start
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .fetchCharacters:
                if state.isFetchingCharacters || state.characters != nil {
                    return .none
                }
                state.fetchCharactersFailMessage = nil
                state.isFetchingCharacters = true
                let characterIds: [Int] = state.episode.characters.compactMap {
                    $0.split(separator: "/").last.flatMap { Int($0) }
                }
                return .run { [characterIds = characterIds] send in
                    do {
                        let characters = try await RickAndMortyApi.shared.getCharacters(by: characterIds)
                        return await send(.fetchCharactersDone(characters))
                    } catch {
                        return await send(
                            .fetchCharactersFailure(error.localizedDescription)
                        )
                    }
                }
            case .fetchCharactersDone(let characters):
                state.isFetchingCharacters = false
                state.characters = characters
                return .none
            case .fetchCharactersFailure(let message):
                state.isFetchingCharacters = false
                state.fetchCharactersFailMessage = message
                return .none
            case .start:
                return .send(.fetchCharacters)
            }
            
        }
    }
}

