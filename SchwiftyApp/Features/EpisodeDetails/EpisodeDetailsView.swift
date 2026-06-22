//
//  EpisodeDetailsView.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeDetailsView: View {
    var store: StoreOf<EpisodeDetailsFeature>
    
    var body: some View {
        List {
            DataSheetItem("Name", store.episode.name, icon: "character.book.closed")
            DataSheetItem("Episode", store.episode.episode, icon: "tv")
            DataSheetItem("Air date", store.episode.air_date, icon: "calendar")
            DataSheetItem("Characters", "\(store.episode.characters.count)", icon: "person.3")
            Section("Characters") {
                if let characters = store.characters {
                    ForEach(characters) { character in
                        Text(character.name)
                    }
                } else if store.isFetchingCharacters {
                    ProgressView().frame(maxWidth: .infinity, idealHeight: 150)
                } else if let fetchCharactersFailMessage = store.fetchCharactersFailMessage {
                    Text(fetchCharactersFailMessage)
                }
            }
        }.navigationTitle("\(store.episode.episode)")
            .onAppear {
                store.send(.start)
            }
    }
}

#Preview("Loaded") {
    EpisodeDetailsView(
        store: Store(initialState: EpisodeDetailsFeature.State(episode: Episode.mock)) {
            EpisodeDetailsFeature()
        }
    )
}

#Preview("Fetching") {
    EpisodeDetailsView(
        store: Store(
            initialState: EpisodeDetailsFeature.State(
                episode: Episode.mock,
                isFetchingCharacters: true
            )
        ) {
            EpisodeDetailsFeature()
        }
    )
}

#Preview("Error") {
    EpisodeDetailsView(
        store: Store(
            initialState: EpisodeDetailsFeature.State(
                episode: Episode.mock,
                characters: nil,
                fetchCharactersFailMessage: "Something went wrong while fetching characters.",
                isFetchingCharacters: false,
            )
        ) {
            EpisodeDetailsFeature()
        }
    )
}
