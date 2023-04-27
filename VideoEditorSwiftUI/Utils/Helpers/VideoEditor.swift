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
    
    
    ///The renderer is made up of half-sequential operations:
    ///1. Cut, resizing and rotate and set quality
    ///2. Adding filters
    ///3. Adding frames
    ///4. Changing time of video
    
    
    func startRender(video: Video, videoQuality: VideoQuality, completion: @escaping (Result<URL, ExporterError>) -> Void){
        /// Starting with the first operation
        resizeVideo(video: video, videoQuality: videoQuality, completion: completion)
    }
    
    
    
    
    ///1. Cut, resizing, rotate and set quality
    private func resizeVideo(video: Video,
                             videoQuality: VideoQuality,
                             completion: @escaping (Result<URL, ExporterError>) -> Void){
        
        
        
        //Create file path
        let tempURL = createTempPath()
        
        let timeRange = getTimeRange(for: video.originalDuration, with: video.rangeDuration)
        let videoTrack = video.asset.tracks(withMediaType: .video).first!
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
        
        
        
        // 1. Set size video
        let layerInstruction = videoCompositionInstructionForTrackWithSizeandTime(track: videoTrack, asset: video.asset, standardSize: outputSize, atTime: .zero)
        
        
        // 2. Mirror video if needed
        if video.isMirror {
            var transform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.translatedBy(x: -outputSize.width, y: 0.0)
            layerInstruction.setTransform(transform, at: .zero)
        }
        
        
        //        layerInstruction.setCropRectangle(.init(x: 100, y: 100, width: 250, height: 250), at: .zero)
        
        //Set Video Composition Instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.layerInstructions = [layerInstruction]
        instruction.timeRange = timeRange
        videoComposition.instructions = [instruction]
        
        
        guard let exportSession = AVAssetExportSession(asset: video.asset, presetName: videoQuality.exportPresetName) else {
            completion(.failure(.cannotCreateExportSession))
            return
        }
        
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
                self.addFiltersToVideo(video, renderSize: outputSize, fromUrl: tempURL, completion: completion)
            case .failed:
                completion(.failure(.failed))
            case .cancelled:
                completion(.failure(.cancelled))
            default:
                completion(.failure(.unknow))
            }
        }
    }
    
    
    ///2. Adding filters
    private func addFiltersToVideo(_ video: Video, renderSize: CGSize, fromUrl: URL, completion: @escaping (Result<URL, ExporterError>) -> Void) {
        
        
        let filters = Helpers.createFilters(mainFilter: CIFilter(name: video.filterName ?? ""), video.colorCorrection)
        
        if filters.isEmpty{
            self.setFrameInVideo(video, renderSize: renderSize, fromURL: fromUrl, completion: completion)
            return
        }
        let asset = AVAsset(url: fromUrl)
        let composition = asset.setFilters(filters)
        
        let tempPath = createTempPath()
        //export the video to as per your requirement conversion
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputFileType = AVFileType.mp4
        exportSession.outputURL = tempPath
        exportSession.videoComposition = composition
        
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status{
                
            case .exporting, .waiting:
                break
            case .completed:
                self.setFrameInVideo(video, renderSize: composition.renderSize, fromURL: fromUrl, completion: completion)
            case .failed:
                completion(.failure(.failed))
            case .cancelled:
                completion(.failure(.cancelled))
            default:
                completion(.failure(.unknow))
            }
        })
    }
    
    ///3. Adding frames
    private func setFrameInVideo(_ video: Video, renderSize: CGSize, fromURL: URL, completion: @escaping (Result<URL, ExporterError>) -> Void){
        
        guard let frame = video.videoFrames else {
            print("FRAME IS NILL")
            videoTimeScale(video, fromURL: fromURL, completion: completion)
            return
        }
        let asset = AVAsset(url: fromURL)
        let videoTrack = asset.tracks(withMediaType: .video).first!
        let naturalSize = renderSize
        //Create video composition
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = naturalSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
    
        let scaledSize = CGSize(width: naturalSize.width * frame.scale, height: naturalSize.height * frame.scale)
        let centerPoint = CGPoint(x: (naturalSize.width - scaledSize.width)/2, y: (naturalSize.height - scaledSize.height)/2)
        
        var scaleTransform = CGAffineTransform(scaleX: frame.scale, y: frame.scale)
        scaleTransform = scaleTransform.translatedBy(x: centerPoint.x, y: centerPoint.y)
      
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.setTransform(scaleTransform, at: .zero)
        

        let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
        videoCompositionInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
        videoCompositionInstruction.backgroundColor = UIColor(frame.frameColor).cgColor

        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(.cannotCreateExportSession))
            return
        }
        
        let tempURL = createTempPath()
        
        
        videoCompositionInstruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [videoCompositionInstruction]
        exportSession.videoComposition = videoComposition
        exportSession.outputURL = tempURL
        exportSession.outputFileType = .mp4
        
        
        exportSession.exportAsynchronously {
            
            switch exportSession.status{
                
            case .exporting, .waiting:
                break
            case .completed:
                self.videoTimeScale(video, fromURL: tempURL, completion: completion)
            case .failed:
                completion(.failure(.failed))
            case .cancelled:
                completion(.failure(.cancelled))
            default:
                completion(.failure(.unknow))
            }
        }
        
    }
    
    
    /// 4. Changing time of video
    private func videoTimeScale(_ video: Video, fromURL url: URL, completion: @escaping (Result<URL, ExporterError>) -> Void) {
        
        if video.rate == 1{
            completion(.success(url))
            return
        }
        
        // Composition Audio Video
        let mixComposition = AVMutableComposition()
        let asset = AVAsset(url: url)
        let timeScale = Float64(video.rate)
        let duration = asset.duration
        
        
        //TotalTimeRange
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        
        /// Video Tracks
        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
        if videoTracks.count == 0 {
            /// Can not find any video track
            return
        }
        
        /// Video track
        let videoTrack = videoTracks.first!
        
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        /// Audio Tracks
        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if audioTracks.count > 0 {
            /// Use audio if video contains the audio track
            let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            /// Audio track
            let audioTrack = audioTracks.first!
            do {
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: CMTime.zero)
                let destinationTimeRange = CMTimeMultiplyByFloat64(duration, multiplier:(1/timeScale))
                compositionAudioTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
                
                compositionAudioTrack?.preferredTransform = audioTrack.preferredTransform
                
            } catch _ {
                /// Ignore audio error
            }
        }
        
        do {
            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
            let destinationTimeRange = CMTimeMultiplyByFloat64(duration, multiplier:(1/timeScale))
            compositionVideoTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
            
            /// Keep original transformation
            compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
            
            //Create Directory path for Save
            let tempPath = createTempPath()
            
            //export the video to as per your requirement conversion
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = tempPath
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status{
                    case .exporting, .waiting:
                        break
                    case .completed:
                        completion(.success(tempPath))
                    case .failed:
                        completion(.failure(.failed))
                    case .cancelled:
                        completion(.failure(.cancelled))
                    default:
                        completion(.failure(.unknow))
                    }
                })
            } else {
                completion(.failure(.failed))
            }
        } catch {
            completion(.failure(.failed))
        }
    }
}


///Helpers
extension VideoEditor{
    
    ///create CMTimeRange
    private func getTimeRange(for duration: Double, with timeRange: ClosedRange<Double>) -> CMTimeRange {
        let start = timeRange.lowerBound.clamped(to: 0...duration)
        let end = timeRange.upperBound.clamped(to: start...duration)
        
        let startTime = CMTimeMakeWithSeconds(start, preferredTimescale: 1000)
        let endTime = CMTimeMakeWithSeconds(end, preferredTimescale: 1000)
        
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        return timeRange
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
    
    
    private func createTempPath() -> URL{
        let tempPath = "\(NSTemporaryDirectory())temp_video.mp4"
        let tempURL = URL(fileURLWithPath: tempPath)
        FileManager.default.removefileExists(for: tempURL)
        return tempURL
    }
}



enum ExporterError: Error, LocalizedError{
    case unknow
    case cancelled
    case cannotCreateExportSession
    case failed
    
}


extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
    
    
    var degTorad: Double {
        return self * .pi / 180
    }
}


