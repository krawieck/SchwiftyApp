//
//  CharacterDetailsView.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI
import ComposableArchitecture

struct CharacterDetailsView: View {
    @Bindable var store: StoreOf<CharacterDetailsFeature>

    var body: some View {
        List {
            header
            
            Section("Data sheet") {
                DataSheetItem("Name", store.character.name, icon: "person.text.rectangle")
                DataSheetItem("Status", store.character.status.rawValue, icon: "heart")
                DataSheetItem("Species", store.character.species, icon: "pawprint")
                DataSheetItem("Gender", store.character.gender.rawValue, icon: "person")
                DataSheetItem("Origin", store.character.origin.name, icon: "globe")
                DataSheetItem("Location", store.character.location.name, icon: "mappin.and.ellipse")
                DataSheetItem("Episodes", "\(store.character.episode.count)", icon: "tv")
            }
        
            episodeListSection
        }
        .navigationDestination(
            item: $store.scope(\.episodeDetails, action: \.episodeDetails)
        ) { store in
            EpisodeDetailsView(store: store)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.toggleFavorite)
                } label: {
                    Label("Favorite", systemImage: store.isFavorite ? "star.fill" : "star")
                }
            }
        }
        .onAppear {
            store.send(.start)
        }
    }
    
    fileprivate var header: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                AsyncImage(url: URL(string: store.character.image)) { image in
                    image
                } placeholder: {
                    ProgressView()
                }
                Text("\(store.character.name)").font(Font.title.bold())
                Text("\(store.character.species)").font(Font.callout)
            }.frame(alignment: .center)
            Spacer()
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    fileprivate var episodeListSection: some View {
        Section("Episodes") {
            if let episodes = store.episodes {
                ForEach(episodes) { episode in
                    Button(action: { store.send(.goToEpisodeDetails(episode)) }) {
                        Label {
                            Text(episode.name)
                            Text(episode.episode)
                        } icon: {}
                    }.foregroundStyle(.foreground)
                }
            } else if let fetchEpisodesFailMessage = store.fetchEpisodesFailMessage {
                ErrorBox(message: fetchEpisodesFailMessage) {
                    store.send(.fetchEpisodes)
                }
            } else if store.isFetchingEpisodes {
                HStack() {
                    Spacer()
                    ProgressView()
                    Spacer()
                }.frame(height: 80)
            } else {
                Text("this text should never appear")
            }
        }
    }
}


#Preview("Loaded") {
    NavigationStack {
        CharacterDetailsView(
            store: Store(
                initialState: CharacterDetailsFeature.State(character: Character.mock)
            ) {
                CharacterDetailsFeature()
            }
        )
    }
}

#Preview("Fetching") {
    NavigationStack {
        CharacterDetailsView(
            store: Store(
                initialState: CharacterDetailsFeature.State(
                    character: Character.mock,
                    isFetchingEpisodes: true
                )
            ) {
                CharacterDetailsFeature()
            }
        )
    }
}

#Preview("Failure") {
    NavigationStack {
        CharacterDetailsView(
            store: Store(
                initialState: CharacterDetailsFeature.State(
                    character: Character.mock,
                    fetchEpisodesFailMessage: "Something went wrong while fetching episodes."
                )
            ) {
                CharacterDetailsFeature()
            }
        )
    }
}
