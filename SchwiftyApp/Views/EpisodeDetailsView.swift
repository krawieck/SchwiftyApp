//
//  EpisodeDetailsView.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeDetailsView: View {
    var store: StoreOf<EpisodeFeature>
    
    var body: some View {
        List {
            
            DataSheetItem("Name", store.episode.name, icon: "character.book.closed")
            DataSheetItem("Episode", store.episode.episode, icon: "tv")
            DataSheetItem("Air date", store.episode.air_date, icon: "calendar")
            DataSheetItem("Characters", "\(store.episode.characters.count)", icon: "person.3")
            
            if let characters = store.characters {
                Section("Characters") {
                    ForEach(characters) { character in
                        Text(character.name)
                    }
                }
            } else if store.isFetchingCharacters {
                Section("Characters") {
                    ProgressView()
                }
            } else if let fetchCharactersFailMessage = store.fetchCharactersFailMessage {
                
            }
            
        }.navigationTitle("\(store.episode.episode)")
            .onAppear {
                store.send(.start)
            }
    }
}

#Preview {
    EpisodeDetailsView(
        store: Store(initialState: EpisodeFeature.State(episode: Episode.mock)) {
            EpisodeFeature()
        }
    )
}
