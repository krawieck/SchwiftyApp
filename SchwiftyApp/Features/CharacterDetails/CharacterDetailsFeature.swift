//
//  CharacterDetailsFeature.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 21/06/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CharacterDetailsFeature {
    @Dependency(\.apiClient) var apiClient
    
    @ObservableState
    struct State: Equatable {
        let character: Character
        var episodes: [Episode]? = nil
        var fetchEpisodesFailMessage: String? = nil
        var isFetchingEpisodes = false
        @Shared(.favorites) var favorites: IdentifiedArrayOf<Character> = []
        var isFavorite: Bool {
            favorites.contains(character)
        }
        
        @Presents var episodeDetails: EpisodeDetailsFeature.State?
    }
    enum Action {
        case fetchEpisodes
        case fetchEpisodesDone([Episode])
        case fetchEpisodesFailure(String)
        case start
        
        case episodeDetails(PresentationAction<EpisodeDetailsFeature.Action>)
        case goToEpisodeDetails(Episode)
        
        case toggleFavorite
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchEpisodes:
                if state.isFetchingEpisodes || state.episodes != nil {
                    return .none
                }
                state.fetchEpisodesFailMessage = nil
                state.isFetchingEpisodes = true
                let episodeIds: [Int] = state.character.episodeNumbers
                return .run { [episodeIds = episodeIds] send in
                    do {
                        let episodes = try await apiClient.getEpisodes(by: episodeIds)
                        return await send(.fetchEpisodesDone(episodes))
                    } catch {
                        return await send(
                            .fetchEpisodesFailure(error.localizedDescription)
                        )
                    }
                }
            case .fetchEpisodesDone(let episodes):
                state.isFetchingEpisodes = false
                state.episodes = episodes
                return .none
            case .fetchEpisodesFailure(let message):
                state.isFetchingEpisodes = false
                state.fetchEpisodesFailMessage = message
                return .none
            case .start:
                return .send(.fetchEpisodes)
            case .episodeDetails:
                return .none
            case .goToEpisodeDetails(let episode):
                state.episodeDetails = EpisodeDetailsFeature.State(episode: episode)
                return .none
            case .toggleFavorite:
                state.$favorites.withLock { $0.toggleFavorite(state.character) }
                return .none
            }
        }
        .ifLet(\.$episodeDetails, action: \.episodeDetails) {
            EpisodeDetailsFeature()
        }
    }
}

