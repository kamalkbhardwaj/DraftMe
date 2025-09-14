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
        VStack {
            // ToDo - later
        }
    }
}

#if DEBUG
#Preview {
    HomeView(model: .init())
}
#endif
