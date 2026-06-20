//
//  CharacterListItem.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI

struct CharacterListItem: View {
    let character: Character
    
    var body: some View {
        NavigationLink {
            CharacterDetailsView(character: character)
        } label: {
            
            HStack{
                AsyncImage(url: character.image) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }.frame(width: 50, height: 50)
            
                VStack(alignment: .leading) {
                    Text(character.name)
                        .font(.headline)
                    Text(character.species)
                        .font(.subheadline)
                }
            }
            
        }
    }
}

#Preview {
    List {
        CharacterListItem(character: Character.mock)
    }
    
}
