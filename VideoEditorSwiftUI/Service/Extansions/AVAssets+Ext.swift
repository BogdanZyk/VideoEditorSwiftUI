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
    
    
    func videoDuration() async -> Double?{
        guard let duration = try? await self.load(.duration) else { return nil }
        
        return duration.seconds
    }
    

//    func resolutionSizeForLocalVideo() -> CGSize? {
//        var unionRect = CGRect.zero
//        for track in self.tracks(withMediaCharacteristic: .visual) {
//            let trackRect = CGRect(x: 0, y: 0, width:
//                                    track.naturalSize.width, height:
//                                    track.naturalSize.height).applying(track.preferredTransform)
//            unionRect = unionRect.union(trackRect)
//            
//        }
//        return unionRect.size
//    }
    
    
    func naturalSize() async -> CGSize? {
        guard let tracks = try? await loadTracks(withMediaType: .video) else { return nil }
        guard let track = tracks.first else { return nil }
        guard let size = try? await track.load(.naturalSize) else { return nil }
        return size
    }
}


