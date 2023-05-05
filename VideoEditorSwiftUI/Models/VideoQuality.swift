//
//  VideoQuality.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 24.04.2023.
//

import Foundation
import AVKit

enum VideoQuality: Int, CaseIterable{
    
    case low, medium, high
    
    
    var exportPresetName:  String {
        switch self {
        case .low:
            return AVAssetExportPresetMediumQuality
        case .high, .medium:
            return AVAssetExportPresetHighestQuality
        }
    }
    
    var title: String{
        switch self {
        case .low: return "qHD - 480"
        case .medium: return "HD - 720p"
        case .high: return "Full HD - 1080p"
        }
    }
    
    var subtitle: String{
        switch self {
        case .low: return "Fast loading and small size, low quality"
        case .medium: return "Optimal size to quality ratio"
        case .high: return "Ideal for publishing on social networks"
        }
    }
    
    var size: CGSize{
        switch self {
        case .low: return .init(width: 854, height: 480)
        case .medium: return .init(width: 1280, height: 720)
        case .high: return .init(width: 1920, height: 1080)
        }
    }
    
    var frameRate: Double{
        switch self {
        case .low, .medium: return 30
        case .high: return 60
        }
    }
    
    var bitrate: Double{
        switch self {
        case .low: return 2.5
        case .medium: return 5
        case .high: return 8
        }
    }
    

    var megaBytesPerSecond: Double {
        let totalPixels = self.size.width * self.size.height
        let bitsPerSecond = bitrate * Double(totalPixels)
        let bytesPerSecond = bitsPerSecond / 8.0 // Convert to bytes
       
        return  bytesPerSecond / (1024 * 1024)
    }

    
    func calculateVideoSize(duration: Double) -> Double? {
       duration * megaBytesPerSecond
    }

}
