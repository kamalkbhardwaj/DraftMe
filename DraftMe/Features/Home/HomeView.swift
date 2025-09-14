//
//  HomeView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import SwiftUI

struct HomeView: View {
    
    @State var model: HomeViewModel
    
    init(model: HomeViewModel) {
        self.model = model
    }
    
    var body: some View {
        NavigationSplitView {
            MenuView()
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            TemplatesView(viewModel: .init())
        }
    }
}

#if DEBUG
#Preview("Portrait") {
    HomeView(model: .init())
}
#endif
