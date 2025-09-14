//
//  TemplatesState.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import Foundation

enum TemplatesState: Sendable {
    case idle
    case loading
    case loaded([Template])
    case error
}

struct Template: Sendable {
    
}
