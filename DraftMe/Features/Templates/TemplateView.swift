//
//  TemplateView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import SwiftUI

struct TemplatesView: View {
    
    @State var model: TemplatesViewModel
    
    init(model: TemplatesViewModel) {
        self.model = model
    }
    
    var body: some View {
        ScrollView {
            gridView
        }
        .scrollIndicators(.hidden)
    }
    
    private var gridView: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(0..<12, id: \.self) { number in
                RoundedRectangle(cornerRadius: 8.0)
                    .foregroundStyle(LinearGradient(colors: [.red.opacity(1.0), .red.opacity(0.3), ], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 160.0)
            }
        }
        .padding()
    }
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 12)]
    }
}

#if DEBUG
#Preview {
    TemplatesView(model: .init())
}
#endif
