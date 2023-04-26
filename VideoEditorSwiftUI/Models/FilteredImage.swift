//
//  FilteredImage.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 26.04.2023.
//

import Foundation
import SwiftUI
import CoreImage

struct FilteredImage: Identifiable{
    var id: UUID = UUID()
    var image: UIImage
    var filter: CIFilter
}

struct CorrectionFilter: Identifiable {
    var id: String { type.key }
    var type: CorrectionType
    var value: Double = 0
    
    
    enum CorrectionType: String, CaseIterable{
        case brightness = "Brightness"
        case contrast = "Contrast"
        case saturation = "Saturation"
        
        var key: String{
            switch self {
            case .brightness: return kCIInputBrightnessKey
            case .contrast: return kCIInputContrastKey
            case .saturation: return kCIInputSaturationKey
            }
        }
    }
    
    static let allFilters: [CorrectionFilter] = CorrectionType.allCases.map({.init(type: $0)})

}


