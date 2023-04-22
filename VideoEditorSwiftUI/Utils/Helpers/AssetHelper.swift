//
//  AssetHelper.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 22.04.2023.
//

import Foundation
import AVFoundation
import UIKit

class AssetHelper{
    
    
    enum VideoQuality {
        
        case low
        case medium
        case high
        
        
        var exportPresetName:  String {
            switch self {
            case .low:
                return AVAssetExportPresetLowQuality
            case .medium:
                return AVAssetExportPresetMediumQuality
            case .high:
                return AVAssetExportPresetHighestQuality
            }
        }
    }
    
//    func transformAVAsset(_ asset: AVAsset,
//                          originalDuration: Double,
//                          rotationAngle: Float,
//                          rate: Float,
//                          timeInterval: ClosedRange<Double>,
//                          mirror: Bool,
//                          videoQuality: VideoQuality = .medium,
//                          completion: @escaping (URL) -> Void) {
//
//
//        /// get video asset track
//        let videoAssetTrack = asset.tracks(withMediaType: .video).first
//        /// get naturalSize video size
//        let videoSize = videoAssetTrack?.naturalSize ?? .zero
//
//        ///get tranform for rotationAngle and mirror
//        let transform = getTransform(for: videoAssetTrack, with: rotationAngle, mirror: mirror)
//        ///get time range
//        let timeRange = getTimeRange(for: originalDuration, with: timeInterval)
//
//        let composition = AVMutableComposition()
//
//        ///set Composition track
//        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
//            return
//        }
//
//        ///set  video and audio compositionTrack
//        do {
//            let videoAssetTrack = asset.tracks(withMediaType: .video).first!
//            try compositionTrack.insertTimeRange(timeRange, of: videoAssetTrack, at: .zero)
//            compositionTrack.preferredTransform = transform
//
//            let audioAssetTrack = asset.tracks(withMediaType: .audio).first!
//            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//            try audioCompositionTrack?.insertTimeRange(timeRange, of: audioAssetTrack, at: .zero)
//        } catch {
//            print("Failed to load asset!")
//            return
//        }
//
//        let videoLayerInstruction = getVideoLayerInstruction(for: compositionTrack, with: transform, forVideoSize: videoSize)
//        let videoCompositionInstruction = getVideoCompositionInstruction(for: compositionTrack, with: timeRange)
//
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.renderSize = videoSize
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//        videoComposition.instructions = [videoCompositionInstruction]
//
//        let audioMix = AVMutableAudioMix()
//        audioMix.inputParameters = [AVMutableAudioMixInputParameters(track: composition.tracks(withMediaType: .audio).first!)]
//
//        let exporter = AVAssetExportSession(asset: composition, presetName: videoQuality.exportPresetName)
//        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.mp4")
//
//        exporter?.outputURL = outputURL
//        exporter?.outputFileType = AVFileType.mp4
//        exporter?.videoComposition = videoComposition
//        exporter?.audioMix = audioMix
//        exporter?.timeRange = timeRange
//
//        guard let url = exporter?.outputURL else {
//            return
//        }
//
//        exporter?.exportAsynchronously {
//            switch exporter?.status {
//            case .completed:
//                print("Видео успешно трансформировано и сохранено по адресу \(url)")
//                completion(url)
//            default:
//                print("Произошла ошибка при экспорте видео: \(exporter?.error?.localizedDescription ?? "Unknown error")")
//            }
//        }
//
//
//    }
//
//    func getTransform(for videoTrack: AVAssetTrack?, with angle: Float, mirror: Bool) -> CGAffineTransform {
//        var transform = CGAffineTransform.identity
//        guard let videoAssetTrack = videoTrack else {
//            return transform
//        }
//
//        let radians = angle * .pi / 180.0
//        transform = videoAssetTrack.preferredTransform.rotated(by: CGFloat(radians))
//
//        if mirror {
//            transform = transform.scaledBy(x: -1, y: 1)
//        }
//
//        return transform
//    }
//
//    func getTimeRange(for duration: Double, with timeRange: ClosedRange<Double>) -> CMTimeRange {
//        let start = timeRange.lowerBound.clamped(to: 0...duration)
//        let end = timeRange.upperBound.clamped(to: start...duration)
//
//        let startTime = CMTimeMakeWithSeconds(start, preferredTimescale: 1000)
//        let endTime = CMTimeMakeWithSeconds(end, preferredTimescale: 1000)
//
//        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
//        return timeRange
//    }
//
//
//    /// Transform video and return AVMutableVideoCompositionLayerInstruction
//    func getVideoLayerInstruction(for track: AVMutableCompositionTrack, with transform: CGAffineTransform, forVideoSize videoSize: CGSize) -> AVMutableVideoCompositionLayerInstruction {
//        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
//            instruction.setTransform(transform, at: .zero)
//
//            let ratio = videoSize.width / videoSize.height
//            let scaleTransform = CGAffineTransform(scaleX: ratio, y: 1)
//            instruction.setTransform(scaleTransform.concatenating(transform), at: .zero)
//
//            return instruction
//    }
//
//    /// create AVMutableVideoCompositionInstruction and set time range
//    func getVideoCompositionInstruction(for track: AVMutableCompositionTrack, with timeRange: CMTimeRange) -> AVMutableVideoCompositionInstruction {
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = timeRange
//
//        let layerInstruction = getVideoLayerInstruction(for: track, with: .identity, forVideoSize: .zero)
//        instruction.layerInstructions = [layerInstruction]
//
//        return instruction
//    }
    
        func getTimeRange(for duration: Double, with timeRange: ClosedRange<Double>) -> CMTimeRange {
            let start = timeRange.lowerBound.clamped(to: 0...duration)
            let end = timeRange.upperBound.clamped(to: start...duration)
    
            let startTime = CMTimeMakeWithSeconds(start, preferredTimescale: 1000)
            let endTime = CMTimeMakeWithSeconds(end, preferredTimescale: 1000)
    
            let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
            return timeRange
        }
    
    
    
    func applyVideoTransforms(asset: AVAsset,
                              originalDuration: Double,
                              rotationAngle: Double,
                              rate: Float,
                              timeInterval: ClosedRange<Double>,
                              mirror: Bool,
                              size: CGSize,
                              videoQuality: VideoQuality = .medium,
                              completion: @escaping (Result<URL, ExporterError>) -> Void){
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: videoQuality.exportPresetName) else {
            completion(.failure(.cannotCreateExportSession))
            return
        }
        
        let tempPath = "\(NSTemporaryDirectory())temp_video.mp4"
        
        let tempURL = URL(fileURLWithPath: tempPath)
        
        FileManager.default.removefileExists(for: tempURL)

        let timeRange = getTimeRange(for: originalDuration, with: timeInterval)
        
        
        let videoComposition = AVMutableVideoComposition()
        
        // Изменяем размер videoComposition в зависимости от поворота видео
        let videoTrack = asset.tracks(withMediaType: .video).first!
        let videoAngleInRadians = CGFloat(rotationAngle * Double.pi / 180)
        if videoAngleInRadians.truncatingRemainder(dividingBy: .pi) == 0 {
            videoComposition.renderSize = size
        } else {
            videoComposition.renderSize = CGSize(width: size.height, height: size.width)
        }
        
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        var transform = CGAffineTransform.identity
        
        // Находим центр видео внутри его отображаемой области
        let videoCenter = CGPoint(x: size.width/2, y: size.height/2)
        
        // Изменяем трансформацию для задания anchorPoint
        transform = transform.concatenating(CGAffineTransform(translationX: -videoCenter.x, y: -videoCenter.y))
        transform = transform.rotated(by: CGFloat(rotationAngle * Double.pi / 180.0))
        transform = transform.concatenating(CGAffineTransform(translationX: videoCenter.x, y: videoCenter.y))

        
        if mirror {
            transform = transform.concatenating(CGAffineTransform(scaleX: -1, y: 1.0))
            transform = transform.concatenating(CGAffineTransform(
                translationX: size.width, y: 0)
            )
        }
        
        transformer.setTransform(transform, at: .zero)


        
        
        //set Video Composition Instruction
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
    


}




extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
    
    
    var degTorad: Double {
        return self * .pi / 180
    }
}
