//
//  MenuView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//
import SwiftUI

struct MenuView: View {
    
    var body: some View {
        List(MenuItem.allCases, id: \.self) { menu in
            Text(menu.rawValue)
                .font(.body)
                .foregroundStyle(Color.primary)
        }
    }
}

extension MenuView {
    enum MenuItem: String, CaseIterable {
        case new = "New Document"
        case templates = "Open"
        case settings = "Settings"
    }
}
