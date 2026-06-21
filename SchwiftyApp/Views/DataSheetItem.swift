//
//  DataSheetItem.swift
//  SchwiftyApp
//
//  Created by Filip Krawczyk on 21/06/2026.
//

import SwiftUI

struct DataSheetItem: View {
    let key: String
    let value: String
    let icon: String
    
    init(_ key: String, _ value: String, icon: String) {
        self.key = key
        self.value = value
        self.icon = icon
    }
    
    var body: some View {
        
        HStack {
            Image(systemName: icon)
            Text("\(key):")
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    List {
        DataSheetItem("Name", "Test Name", icon: "character.book.closed")
        DataSheetItem("Episode", "S01E04", icon: "tv")
        DataSheetItem("Air date", "12 Sep, 2023", icon: "calendar")
        DataSheetItem("Characters", "12", icon: "person.3")
        DataSheetItem("URL", "https://asdasd", icon: "link")
        DataSheetItem("Created", "asdasd", icon: "clock")
    }
}
