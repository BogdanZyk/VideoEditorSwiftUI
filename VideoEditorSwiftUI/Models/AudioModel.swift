//
//  AudioModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 04.05.2023.
//

import SwiftUI


struct Audio: Identifiable, Equatable{
    
    var id: UUID = UUID()
    var url: URL
    var duration: Double
    
    
    func createSimples(_ size: CGFloat) -> [AudioSimple]{
        let simplesCount = Int(size / 3)
        return (1...simplesCount).map({.init(id: $0)})
    }
    
    struct AudioSimple: Identifiable{
        var id: Int
        var size: CGFloat = CGFloat((5...25).randomElement() ?? 5)
    }
}
