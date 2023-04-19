//
//  AVAssets+Ext.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 16.04.2023.
//

import Foundation
import AVKit
import SwiftUI

extension AVAsset {
    func assetByTrimming(startTime: CMTime, endTime: CMTime) throws -> AVAsset {
        let duration = CMTimeSubtract(endTime, startTime)
        let timeRange = CMTimeRange(start: startTime, duration: duration)
        
        let composition = AVMutableComposition()
        
        do {
            for track in tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                compositionTrack?.preferredTransform = track.preferredTransform
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
            }
        } catch let error {
            throw TrimError("error during composition", underlyingError: error)
        }
        
        return composition
    }
    
    struct TrimError: Error {
        let description: String
        let underlyingError: Error?
        
        init(_ description: String, underlyingError: Error? = nil) {
            self.description = "TrimVideo: " + description
            self.underlyingError = underlyingError
        }
    }
    
    func getImage(_ second: Int, compressionQuality: Double = 0.05) -> Image?{
        let imgGenerator = AVAssetImageGenerator(asset: self)
        guard let cgImage = try? imgGenerator.copyCGImage(at: .init(seconds: Double(second), preferredTimescale: 1), actualTime: nil) else { return nil}
        let uiImage = UIImage(cgImage: cgImage)
        guard let imageData = uiImage.jpegData(compressionQuality: compressionQuality), let compressedUIImage = UIImage(data: imageData) else { return nil }
        return Image(uiImage: compressedUIImage)
    }
    
    
    func videoDuration() -> Double{
        self.duration.seconds
    }
    
    
}


