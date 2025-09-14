//
//  CanvasView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import SwiftUI

struct CanvasView: View {
    
    @State var model: CanvasViewModel
    
    init(model: CanvasViewModel) {
        self.model = model
    }
    
    var body: some View {
        Text("CanvasView")
    }
}
