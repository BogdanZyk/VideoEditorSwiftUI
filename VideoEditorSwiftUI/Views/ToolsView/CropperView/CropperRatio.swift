//
//  CropperRatio.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import Foundation
import CoreGraphics

struct CropperRatio {
    
    let width: CGFloat
    let height: CGFloat
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
    
    static var r_1_1: Self {
        return .init(width: 1, height: 1)
    }
    
    static var r_3_2: Self {
        return .init(width: 3, height: 2)
    }
    
    static var r_4_3: Self {
        return .init(width: 4, height: 3)
    }
    
    static var r_16_9: Self {
        return .init(width: 16, height: 9)
    }
    
    static var r_18_6: Self {
        return .init(width: 18, height: 6)
    }
}
