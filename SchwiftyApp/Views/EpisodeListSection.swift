//
//  EpisodeListSection.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeListSection: View {
    let store: StoreOf<CharacterDetailsFeature>
    
    var body: some View {
        Section("Episodes") {
            if let episodes = store.episodes {
                ForEach(episodes) { episode in
                    Text(episode.name)
                }
            } else if let fetchEpisodesFailMessage = store.fetchEpisodesFailMessage {
                
                HStack {
                    Text(fetchEpisodesFailMessage)
                    Spacer()
                    Button("Retry") {
                        store.send(.fetchEpisodes)
                    }.buttonStyle(.bordered)
                }
            } else if store.isFetchingEpisodes {
                HStack() {
                    Spacer()
                    ProgressView()
                    Spacer()
                }.frame(height: 80)
            } else {
                Text("unreachable")
            }
        }
    }
}


#Preview("With episodes") {
    List {
        EpisodeListSection(
            store: Store(
                initialState: CharacterDetailsFeature.State(
                    character: .mock,
                    episodes: [.mock]
                )
            ) {
                CharacterDetailsFeature()
            }
        )
    }
}

#Preview("Fail state") {
    List {
        EpisodeListSection(
            store: Store(
                initialState: CharacterDetailsFeature.State(
                    character: .mock,
                    fetchEpisodesFailMessage: "Failed to fetch episodes"
                )
            ) {
                CharacterDetailsFeature()
            }
        )
    }
}
