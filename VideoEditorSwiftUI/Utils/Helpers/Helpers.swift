//
//  Helpers.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 27.04.2023.
//

import Foundation
import CoreImage

final class Helpers{
    
    
    static func createColorFilter(_ colorCorrection: ColorCorrection?) -> CIFilter?{
        guard  let colorCorrection else { return nil }
        let colorCorrectionFilter = CIFilter(name: "CIColorControls")
        colorCorrectionFilter?.setValue(colorCorrection.brightness, forKey: CorrectionType.brightness.key)
        colorCorrectionFilter?.setValue(colorCorrection.contrast + 1, forKey: CorrectionType.contrast.key)
        colorCorrectionFilter?.setValue(colorCorrection.saturation + 1, forKey: CorrectionType.saturation.key)
        return colorCorrectionFilter
    }
    
    
    static func createFilters(mainFilter: CIFilter?, _ colorCorrection: ColorCorrection?) -> [CIFilter]{
        var filters = [CIFilter]()
        
        if let mainFilter{
            filters.append(mainFilter)
        }
        
        if let colorFilter = createColorFilter(colorCorrection){
            filters.append(colorFilter)
        }
        
        return filters
    }
}
