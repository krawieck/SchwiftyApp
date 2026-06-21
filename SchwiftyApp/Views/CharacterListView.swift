//
//  CharacterListView.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI
import ComposableArchitecture

struct CharacterListView: View {
    @Bindable var store: StoreOf<CharacterList>
    
    var body: some View {
        
        List {
            ForEach(store.characters) { character in
                Button {
                    store.send(.goToCharacter(character: character))
                } label: {
                    HStack {
                        CharacterListItem(character: character)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
                .listRowSeparator(.visible)
            }
            
           
            LoadMoreView(store: store)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }.navigationDestination(
            item: $store
                .scope(\.characterDetails, action: \.characterDetails)
        ) { store in
            CharacterDetailsView(store: store)
        }
        .onAppear {
            store.send(.start)
        }.refreshable {
            await store.send(.refresh).finish()
        }
            
    }
}

#Preview {
    NavigationStack {
        CharacterListView(
            store: Store(
                initialState: CharacterList.State(characters: [.mock])
            ) {
                CharacterList()
            }
        )
    }
}

struct LoadMoreView: View {
    let store: StoreOf<CharacterList>
    var body: some View {
        if store.characters.isEmpty {
            if store.fetching {
                ProgressView()
            } else {
                Text("nothing is happening")
            }
        } else if store.canFetchMore {
            if let fetchingError = store.fetchingError  {
                GroupBox(label: Label(fetchingError, systemImage: "exclamationmark.triangle.fill")) {
                    Button("Retry") {
                        store.send(.fetchCharacters)
                    }
                }
            } else {
               ProgressView()
                    .onAppear {
                        store.send(.fetchCharacters)
                    }
                
            }
        }
    
    }
}
