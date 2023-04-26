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

struct CorrectionFilter {
    
    var key: String
    var value: Double
//    var colorCorrectionFilter: CIFilter
//    var value: Double
//
//
//    mutating func changeValue(_ value: Double, for key: String){
//
//    }
}

