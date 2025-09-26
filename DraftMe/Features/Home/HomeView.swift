//
//  HomeView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import SwiftUI

struct HomeView: View {
    
    @State var model: HomeViewModel
    @State var selectedMenu: MenuView.Destination = .new
    
    init(model: HomeViewModel) {
        self.model = model
    }
    
    var body: some View {
        NavigationSplitView {
            MenuView(selected: $selectedMenu)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            withAnimation(.easeIn(duration: 0.5)) {
                selectedMenu.destination
            }
        }
    }
}

#if DEBUG
#Preview("Portrait") {
    HomeView(model: .init())
}
#endif
