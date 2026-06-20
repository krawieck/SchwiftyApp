//
//  CharacterDetailsView.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI

struct CharacterDetailsView: View {
    let character: Character
    
    var body: some View {
        List {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    AsyncImage(url: character.image)
                        .cornerRadius(15)
                    Text("\(character.name)").font(Font.title.bold())
                    Text("\(character.species)").font(Font.callout)
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
                    Text(character.name)
                }
                HStack {
                    Image(systemName: "heart")
                    Text("Status:")
                    Spacer()
                    Text(character.status.rawValue)
                }
                HStack {
                    Image(systemName: "pawprint")
                    Text("Species:")
                    Spacer()
                    Text(character.species)
                }
                 HStack {
                    Image(systemName: "person")
                    Text("Gender:")
                    Spacer()
                    Text(character.gender.rawValue)
                }
                HStack {
                    Image(systemName: "globe")
                    Text("Origin:")
                    Spacer()
                    Text(character.origin.name)
                }
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Location:")
                    Spacer()
                    Text(character.location.name)
                }
                HStack {
                    Image(systemName: "tv")
                    Text("Episodes:")
                    Spacer()
                    Text("\(character.episode.count)")
                }
            }
            
            EpisodeListSection(episodeLinks: character.episode)
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Label("Favorite", systemImage: "star")
                }
            }
        }
    }
}



#Preview {
    NavigationStack {
        CharacterDetailsView(character: Character.mock)
    }
}
