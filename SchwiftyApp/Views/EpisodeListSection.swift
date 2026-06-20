//
//  EpisodeListSection.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 20/06/2026.
//

import SwiftUI

struct EpisodeListSection: View {
    let episodeLinks: [URL]
    var body: some View {
        Section("Episodes") {
            ProgressView()
        }
    }
}


#Preview {
    List {
        EpisodeListSection(episodeLinks: Character.mock.episode)
    }
}
