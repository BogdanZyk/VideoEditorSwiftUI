//
//  VideoEditor.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 22.04.2023.
//

import Foundation
import AVFoundation
import UIKit

class VideoEditor{
    
    
    func applyVideoTransforms(asset: AVAsset,
                              originalDuration: Double,
                              rotationAngle: Double,
                              rate: Float,
                              timeInterval: ClosedRange<Double>,
                              mirror: Bool,
                              videoQuality: VideoQuality,
                              completion: @escaping (Result<URL, ExporterError>) -> Void){
        
        
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: videoQuality.exportPresetName) else {
            completion(.failure(.cannotCreateExportSession))
            return
        }
        
        //Create file path
        let tempPath = "\(NSTemporaryDirectory())temp_video.mp4"
        let tempURL = URL(fileURLWithPath: tempPath)
        FileManager.default.removefileExists(for: tempURL)
        
        
        let timeRange = getTimeRange(for: originalDuration, with: timeInterval)
        let videoTrack = asset.tracks(withMediaType: .video).first!
        var outputSize = videoQuality.size
        let naturalSize = videoTrack.naturalSize
        
        // Determine video output size
        let assetInfo = self.orientationFromTransform(videoTrack.preferredTransform)

        var videoSize = naturalSize
        if assetInfo.isPortrait == true {
            videoSize.width = naturalSize.height
            videoSize.height = naturalSize.width
        }
        
        if videoSize.height > outputSize.height {
            outputSize = videoSize
        }
        
    
        // Create video composition
        let videoComposition = AVMutableVideoComposition()
        
        videoComposition.renderSize = outputSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        
        // Set transformer, create new video layer size
        let transformer = videoCompositionInstructionForTrackWithSizeandTime(track: videoTrack, asset: asset, standardSize: outputSize, atTime: .zero)
        
        
        //Set Video Composition Instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.layerInstructions = [transformer]
        instruction.timeRange = timeRange

        videoComposition.instructions = [instruction]
        
        exportSession.videoComposition = videoComposition
        
        exportSession.outputURL = tempURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.timeRange = timeRange
        
        
        
        exportSession.exportAsynchronously {
            
            switch exportSession.status{
                
            case .exporting, .waiting:
                break
            case .completed:
                completion(.success(tempURL))
            case .failed:
                completion(.failure(.failed))
            case .cancelled:
                completion(.failure(.cancelled))
            default:
                completion(.failure(.unknow))
            }
        }
        
    }
    

    enum ExporterError: Error, LocalizedError{
        case unknow
        case cancelled
        case cannotCreateExportSession
        case failed
        
        
    }
    
   private func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    
    ///set video size for AVMutableVideoCompositionLayerInstruction
   private func videoCompositionInstructionForTrackWithSizeandTime(track: AVAssetTrack, asset: AVAsset, standardSize:CGSize, atTime: CMTime) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let naturalSize = assetTrack.naturalSize
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var aspectFillRatio:CGFloat = 1
        if naturalSize.height < naturalSize.width {
            aspectFillRatio = standardSize.height / assetTrack.naturalSize.height
        }
        else {
            aspectFillRatio = standardSize.width / naturalSize.width
        }
        
        if assetInfo.isPortrait {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            let posX = standardSize.width/2 - (naturalSize.height * aspectFillRatio)/2
            let posY = standardSize.height/2 - (naturalSize.width * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor), at: atTime)
            
        } else {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width/2 - (naturalSize.width * aspectFillRatio)/2
            let posY = standardSize.height/2 - (naturalSize.height * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)
            
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
            }
            instruction.setTransform(concat, at: atTime)
        }
        return instruction
    }

    ///create CMTimeRange
    private func getTimeRange(for duration: Double, with timeRange: ClosedRange<Double>) -> CMTimeRange {
          let start = timeRange.lowerBound.clamped(to: 0...duration)
          let end = timeRange.upperBound.clamped(to: start...duration)
  
          let startTime = CMTimeMakeWithSeconds(start, preferredTimescale: 1000)
          let endTime = CMTimeMakeWithSeconds(end, preferredTimescale: 1000)
  
          let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
          return timeRange
      }
}




extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
    
    
    var degTorad: Double {
        return self * .pi / 180
    }
}



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
    
//    func calculateVideoSize(duration: Double) -> Double? {
//
//        let width = Double(self.size.width)
//        let height = Double(self.size.height)
//
//        let totalPixels = width * height
//
//        let totalBits = totalPixels * self.bitrate * duration * self.frameRate
//
//        let totalMegabits = totalBits / 1000000.0
//
//        return totalMegabits/8.0  // convert from bits to bytes
//    }
    
    
    
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
