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
            Section("Data sheet") {
                HStack {
                    Image(systemName: "person.text.rectangle")
                    Text("Name:")
                    Spacer()
                    Text(store.character.name)
                }
                HStack {
                    Image(systemName: "heart")
                    Text("Status:")
                    Spacer()
                    Text(store.character.status.rawValue)
                }
                HStack {
                    Image(systemName: "pawprint")
                    Text("Species:")
                    Spacer()
                    Text(store.character.species)
                }
                 HStack {
                    Image(systemName: "person")
                    Text("Gender:")
                    Spacer()
                    Text(store.character.gender.rawValue)
                }
                HStack {
                    Image(systemName: "globe")
                    Text("Origin:")
                    Spacer()
                    Text(store.character.origin.name)
                }
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Location:")
                    Spacer()
                    Text(store.character.location.name)
                }
                HStack {
                    Image(systemName: "tv")
                    Text("Episodes:")
                    Spacer()
                    Text("\(store.character.episode.count)")
                }
            }
            
            EpisodeListSection(store: store)
        }
            .navigationDestination(
                item: $store.scope(\.episodeDetails, action: \.episodeDetails)
            ) { store in
                EpisodeDetailsView(store: store)
            }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Label("Favorite", systemImage: "star")
                }
            }
        }.onAppear {
            store.send(.start)
        }
    }
}


#Preview {
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
