//
//  MenuView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//
import SwiftUI

struct MenuView: View {
    
    @Binding var selected: Destination
    
    var body: some View {
        List(Destination.allCases, id: \.self) { destination in
            Text(destination.rawValue)
                .font(.body)
                .foregroundStyle(Color.primary)
                .onTapGesture {
                    self.selected = destination
                }
        }
    }
}

extension MenuView {
    enum Destination: String, CaseIterable {
        case new = "New Document"
        case templates = "Open"
        case settings = "Settings"
        
        @ViewBuilder
        var destination: some View {
            switch self {
            case .new:
                CanvasView(model: .init())
            case .templates:
                TemplatesView(model: .init())
            case .settings:
                EmptyView()
            }
        }
    }
}
