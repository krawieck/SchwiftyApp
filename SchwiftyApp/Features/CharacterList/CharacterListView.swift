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
            if !store.favorites.isEmpty {
                Section("Favorites") {
                    ForEach(store.favorites) { character in
                        characterListItem(character)
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.send(.removeFromFavorites(character))
                                } label: {
                                    Label("Unfavorite", systemImage: "star.slash.fill")
                                }
                            }
                    }
                }
            }
            
            ForEach(store.characters) { character in
                characterListItem(character)
            }
            
            LoadMoreView(store: store)
        }
        .navigationDestination(
            item: $store
                .scope(\.characterDetails, action: \.characterDetails)
        ) { store in
            CharacterDetailsView(store: store)
        }
        .onAppear {
            store.send(.start)
        }
        .refreshable {
            await store.send(.refresh).finish()
        }
    }
    
    func characterListItem(_ character: Character) -> some View {
        Button {
            store.send(.goToCharacter(character: character))
        } label: {
            HStack {
                HStack{
                    Label {
                        VStack(alignment: .leading) {
                            Text(character.name)
                                .font(.headline)
                            Text(character.species)
                                .font(.subheadline)
                        }
                    } icon: {
                        EmptyView()
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .foregroundStyle(.foreground)
        
        
        
    }
}

struct LoadMoreView: View {
    let store: StoreOf<CharacterList>
    var body: some View {
        if let fetchingError = store.fetchingError  {
            ErrorBox(message: fetchingError) {
                store.send(.fetchCharacters)
            }
        } else if store.canFetchMore {
            ProgressView()
                .frame(
                    maxWidth: .infinity,
                    idealHeight: 100,
                )
                .onAppear {
                    store.send(.fetchCharacters)
                }
        }
        EmptyView()
    }
}


#Preview("Loaded") {
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

#Preview("Fetching (No Content)") {
    NavigationStack {
        CharacterListView(
            store: Store(
                initialState: CharacterList.State(fetching: true, characters: [])
            ) {
                CharacterList()
            }
        )
    }
}

#Preview("Fetching") {
    NavigationStack {
        CharacterListView(
            store: Store(
                initialState: CharacterList.State(fetching: true, characters: [.mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock])
            ) {
                CharacterList()
            }
        )
    }
}


#Preview("Failure") {
    NavigationStack {
        CharacterListView(
            store: Store(
                initialState: CharacterList.State(
                    fetching: true,
                    fetchingError: "Something went wrong while fetching characters.",
                    canFetchMore: true,
                    characters: [.mock]
                )
            ) {
                CharacterList()
            }
        )
    }
}
