//
//  ErrorBox.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 22/06/2026.
//

import SwiftUI

struct ErrorBox: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        HStack {
            Text(message)
            Spacer()
            Button("Retry") {
                retryAction()
            }.buttonStyle(.bordered)
        }
    }
}
