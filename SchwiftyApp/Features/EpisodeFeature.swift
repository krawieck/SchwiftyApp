//
//  EpisodeFeature.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 21/06/2026.
//

import ComposableArchitecture

@Reducer
struct EpisodeFeature {
    @ObservableState
    struct State: Equatable {
        let episode: Episode
    }
    enum Action {
        
    }
    
    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            
//            
//        }
    }
}

