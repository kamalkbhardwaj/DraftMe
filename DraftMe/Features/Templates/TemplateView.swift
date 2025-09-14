//
//  TemplateView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import SwiftUI

struct TemplatesView: View {
    
    @State var viewModel: TemplatesViewModel
    @State var orientation: UIDeviceOrientation = .portrait
    
    init(viewModel: TemplatesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            gridView
        }
        .scrollIndicators(.hidden)
        .onAppear {
            self.orientation = UIDevice.current.orientation
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            self.orientation = UIDevice.current.orientation
        }
    }
    
    private var gridView: some View {
        LazyVGrid(columns: columns) {
            ForEach(0..<12, id: \.self) { number in
                RoundedRectangle(cornerRadius: 8.0)
                    .foregroundStyle(LinearGradient(colors: [.red.opacity(1.0), .red.opacity(0.3), ], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 160.0)
            }
        }
        .padding()
    }
    
    private var columns: [GridItem] {
        let gridItem: GridItem = .init(.flexible())
        return .init(repeating: gridItem, count: orientation == .portrait ? 3 : 4)
    }
}

#if DEBUG
#Preview("Portrait") {
    TemplatesView(viewModel: .init())
}
#Preview("Landscape Left", traits: .landscapeLeft) {
    TemplatesView(viewModel: .init())
}
#endif
