//
//  ContentView.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 16/06/2026.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        NavigationStack {
            CharacterListView(
                store: Store(initialState: CharacterList.State()) {
                    CharacterList()
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
