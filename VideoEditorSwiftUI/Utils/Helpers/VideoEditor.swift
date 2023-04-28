//
//  VideoEditor.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 22.04.2023.
//

import Foundation
import AVFoundation
import UIKit
import Combine

class VideoEditor{
    
    @Published var currentTimePublisher: TimeInterval = 0.0
    
    
    ///The renderer is made up of half-sequential operations:
    ///1. Cut, resizing and rotate and set quality
    ///2. Adding filters
    ///3. Adding frames
    ///4. Changing time of video
    func startRender(video: Video, videoQuality: VideoQuality) async throws -> URL{
        do{
            let url = try await exporterForVideo(video: video, videoQuality: videoQuality)
            return url
        }catch{
            throw error
        }
    }
    
    
    
   private func exporterForVideo(video: Video,
                videoQuality: VideoQuality) async throws -> URL{
        
        
        let composition = AVMutableComposition()
        
        let timeRange = getTimeRange(for: video.originalDuration, with: video.rangeDuration)
        let asset = video.asset
        
        ///Set new timeScale
        try await setTimeScaleForTracks(to: composition, from: asset, timeScale: Float64(video.rate))
        
        ///Get new timeScale video track
        guard let videoTrack = try await composition.loadTracks(withMediaType: .video).first else {
            throw ExporterError.unknow
        }

        ///Prepair new video size
        let naturalSize = videoTrack.naturalSize
        let videoTrackPreferredTransform = try await videoTrack.load(.preferredTransform)
        let outputSize = getSizeFromOrientation(newSize: videoQuality.size, videoTrackPreferredTransform: videoTrackPreferredTransform)
        
        
        ///Create mutable video composition
        let videoComposition = AVMutableVideoComposition()
        
        ///Set rander video  size
        videoComposition.renderSize = outputSize
        ///Set frame duration 30fps
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        ///Create layerInstructions and set new size, scale, mirror
        let layerInstruction = videoCompositionInstructionForTrackWithSizeAndTime(
            
            preferredTransform: videoTrackPreferredTransform,
            naturalSize: naturalSize,
            newSize: outputSize,
            track: videoTrack,
            scale: video.videoFrames?.scale ?? 1,
            isMirror: video.isMirror
        )
        
        ///Set Video Composition Instruction
        let instruction = AVMutableVideoCompositionInstruction()
        /// set video backgroundColor
        if let color = video.videoFrames?.frameColor{
            instruction.backgroundColor = UIColor(color).cgColor
        }
        
        ///Set time range
        instruction.timeRange = timeRange
        instruction.layerInstructions = [layerInstruction]
        
        ///Set instruction in videoComposition
        videoComposition.instructions = [instruction]
        
        ///Create file path in temp directory
        let outputURL = createTempPath()
        
        ///Create exportSession
        let session = try exportSession(composition: composition, videoComposition: videoComposition, outputURL: outputURL, timeRange: timeRange)
        
        await session.export()
        
        if let error = session.error {
            throw error
        } else {
            if let url = session.outputURL{
                return url
            }
            throw ExporterError.failed
        }
    }
    
    
    func exportSession(composition: AVMutableComposition, videoComposition: AVMutableVideoComposition, outputURL: URL, timeRange: CMTimeRange) throws -> AVAssetExportSession {
        guard let export = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            print("Cannot create export session.")
            throw ExporterError.cannotCreateExportSession
        }
        export.videoComposition = videoComposition
        export.outputFileType = .mp4
        export.outputURL = outputURL
        export.timeRange = timeRange
        
        return export
    }
    

    
    
//    ///1. Cut, resizing, rotate and set quality
//    private func resizeVideo(video: Video,
//                             videoQuality: VideoQuality,
//                             completion: @escaping (Result<URL, ExporterError>) -> Void){
//
//
//
//        //Create file path
//        let tempURL = createTempPath()
//
//        let timeRange = getTimeRange(for: video.originalDuration, with: video.rangeDuration)
//        let videoTrack = video.asset.tracks(withMediaType: .video).first!
//        var outputSize = videoQuality.size
//        let naturalSize = videoTrack.naturalSize
//
//        // Determine video output size
//        let assetInfo = self.orientationFromTransform(videoTrack.preferredTransform)
//
//        var videoSize = naturalSize
//        if assetInfo.isPortrait == true {
//            videoSize.width = naturalSize.height
//            videoSize.height = naturalSize.width
//        }
//
//        if videoSize.height > outputSize.height {
//            outputSize = videoSize
//        }
//
//
//        // Create video composition
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.renderSize = outputSize
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//
//
//
//        // 1. Set size video
//        let layerInstruction = videoCompositionInstructionForTrackWithSizeandTime(track: videoTrack, asset: video.asset, standardSize: outputSize, atTime: .zero)
//
//
//        // 2. Mirror video if needed
//        if video.isMirror {
//            var transform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//            transform = transform.translatedBy(x: -outputSize.width, y: 0.0)
//            layerInstruction.setTransform(transform, at: .zero)
//        }
//
//
//        //        layerInstruction.setCropRectangle(.init(x: 100, y: 100, width: 250, height: 250), at: .zero)
//
//        //Set Video Composition Instruction
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.layerInstructions = [layerInstruction]
//        instruction.timeRange = timeRange
//        videoComposition.instructions = [instruction]
//
//
//        guard let exportSession = AVAssetExportSession(asset: video.asset, presetName: videoQuality.exportPresetName) else {
//            completion(.failure(.cannotCreateExportSession))
//            return
//        }
//
//        exportSession.videoComposition = videoComposition
//
//        exportSession.outputURL = tempURL
//        exportSession.outputFileType = .mp4
//        exportSession.shouldOptimizeForNetworkUse = true
//        exportSession.timeRange = timeRange
//
//
//
//        exportSession.exportAsynchronously {
//
//            switch exportSession.status{
//
//            case .exporting, .waiting:
//                break
//            case .completed:
//                self.addFiltersToVideo(video, renderSize: outputSize, fromUrl: tempURL, completion: completion)
//            case .failed:
//                completion(.failure(.failed))
//            case .cancelled:
//                completion(.failure(.cancelled))
//            default:
//                completion(.failure(.unknow))
//            }
//        }
//    }
    
    
//    ///2. Adding filters
//    private func addFiltersToVideo(_ video: Video, renderSize: CGSize, fromUrl: URL, completion: @escaping (Result<URL, ExporterError>) -> Void) {
//
//
//        let filters = Helpers.createFilters(mainFilter: CIFilter(name: video.filterName ?? ""), video.colorCorrection)
//
//        if filters.isEmpty{
//            self.setFrameInVideo(video, renderSize: renderSize, fromURL: fromUrl, completion: completion)
//            return
//        }
//        let asset = AVAsset(url: fromUrl)
//        let composition = asset.setFilters(filters)
//
//
//        let tempPath = createTempPath()
//        //export the video to as per your requirement conversion
//        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
//        exportSession.outputFileType = AVFileType.mp4
//        exportSession.outputURL = tempPath
//        exportSession.videoComposition = composition
//
//        exportSession.exportAsynchronously(completionHandler: {
//            switch exportSession.status{
//
//            case .exporting, .waiting:
//                break
//            case .completed:
//                self.setFrameInVideo(video, renderSize: composition.renderSize, fromURL: fromUrl, completion: completion)
//            case .failed:
//                completion(.failure(.failed))
//            case .cancelled:
//                completion(.failure(.cancelled))
//            default:
//                completion(.failure(.unknow))
//            }
//        })
//    }
//
//    ///3. Adding frames
//    private func setFrameInVideo(_ video: Video, renderSize: CGSize, fromURL: URL, completion: @escaping (Result<URL, ExporterError>) -> Void){
//
//        guard let frame = video.videoFrames else {
//            print("FRAME IS NILL")
//            videoTimeScale(video, fromURL: fromURL, completion: completion)
//            return
//        }
//        let asset = AVAsset(url: fromURL)
//        let videoTrack = asset.tracks(withMediaType: .video).first!
//        let naturalSize = renderSize
//        //Create video composition
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.renderSize = naturalSize
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//
//        let scaledSize = CGSize(width: naturalSize.width * frame.scale, height: naturalSize.height * frame.scale)
//        let centerPoint = CGPoint(x: (naturalSize.width - scaledSize.width)/2, y: (naturalSize.height - scaledSize.height)/2)
//
//        var scaleTransform = CGAffineTransform(scaleX: frame.scale, y: frame.scale)
//        scaleTransform = scaleTransform.translatedBy(x: centerPoint.x, y: centerPoint.y)
//
//        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
//        layerInstruction.setTransform(scaleTransform, at: .zero)
//
//
//        let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
//        videoCompositionInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
//        videoCompositionInstruction.backgroundColor = UIColor(frame.frameColor).cgColor
//
//
//        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
//            completion(.failure(.cannotCreateExportSession))
//            return
//        }
//
//        let tempURL = createTempPath()
//
//
//        videoCompositionInstruction.layerInstructions = [layerInstruction]
//        videoComposition.instructions = [videoCompositionInstruction]
//        exportSession.videoComposition = videoComposition
//        exportSession.outputURL = tempURL
//        exportSession.outputFileType = .mp4
//
//
//        exportSession.exportAsynchronously {
//
//            switch exportSession.status{
//
//            case .exporting, .waiting:
//                break
//            case .completed:
//                self.videoTimeScale(video, fromURL: tempURL, completion: completion)
//            case .failed:
//                completion(.failure(.failed))
//            case .cancelled:
//                completion(.failure(.cancelled))
//            default:
//                completion(.failure(.unknow))
//            }
//        }
//
//    }
//
    

    
//    /// 4. Changing time of video
//    private func videoTimeScale(_ video: Video, fromURL url: URL, completion: @escaping (Result<URL, ExporterError>) -> Void) {
//
//        if video.rate == 1{
//            completion(.success(url))
//            return
//        }
//
//        // Composition Audio Video
//        let mixComposition = AVMutableComposition()
//        let asset = AVAsset(url: url)
//        let timeScale = Float64(video.rate)
//        let duration = asset.duration
//
//
//        //TotalTimeRange
//        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
//
//        /// Video Tracks
//        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
//        if videoTracks.count == 0 {
//            /// Can not find any video track
//            return
//        }
//
//        /// Video track
//        let videoTrack = videoTracks.first!
//
//        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
//
//        /// Audio Tracks
//        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)
//        if audioTracks.count > 0 {
//            /// Use audio if video contains the audio track
//            let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//
//            /// Audio track
//            let audioTrack = audioTracks.first!
//            do {
//                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: CMTime.zero)
//                let destinationTimeRange = CMTimeMultiplyByFloat64(duration, multiplier:(1/timeScale))
//                compositionAudioTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
//
//                compositionAudioTrack?.preferredTransform = audioTrack.preferredTransform
//
//            } catch _ {
//                /// Ignore audio error
//            }
//        }
//
//        do {
//            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
//            let destinationTimeRange = CMTimeMultiplyByFloat64(duration, multiplier:(1/timeScale))
//            compositionVideoTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
//
//            /// Keep original transformation
//            compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
//
//            //Create Directory path for Save
//            let tempPath = createTempPath()
//
//            //export the video to as per your requirement conversion
//            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
//                exportSession.outputURL = tempPath
//                exportSession.outputFileType = AVFileType.mp4
//                exportSession.shouldOptimizeForNetworkUse = true
//                /// try to export the file and handle the status cases
//                exportSession.exportAsynchronously(completionHandler: {
//                    switch exportSession.status{
//                    case .exporting, .waiting:
//                        break
//                    case .completed:
//                        completion(.success(tempPath))
//                    case .failed:
//                        completion(.failure(.failed))
//                    case .cancelled:
//                        completion(.failure(.cancelled))
//                    default:
//                        completion(.failure(.unknow))
//                    }
//                })
//            } else {
//                completion(.failure(.failed))
//            }
//        } catch {
//            completion(.failure(.failed))
//        }
//    }
}


///Helpers
extension VideoEditor{
    
    ///Set new time scale for audio and video tracks
    private func setTimeScaleForTracks(to composition: AVMutableComposition, from asset: AVAsset, timeScale: Float64) async throws{
        
        let videoTracks =  try await asset.loadTracks(withMediaType: .video)
        let audioTracks = try await asset.loadTracks(withMediaType: .audio)
        
        let duration = try await asset.load(.duration)
        
        //TotalTimeRange
        let oldTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        let destinationTimeRange = CMTimeMultiplyByFloat64(duration, multiplier:(1/timeScale))
        // set new time range in audio track
        if audioTracks.count > 0 {
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            let audioTrack = audioTracks.first!
            try compositionAudioTrack?.insertTimeRange(oldTimeRange, of: audioTrack, at: CMTime.zero)
            compositionAudioTrack?.scaleTimeRange(oldTimeRange, toDuration: destinationTimeRange)
            
            let auduoPreferredTransform = try await audioTrack.load(.preferredTransform)
            compositionAudioTrack?.preferredTransform = auduoPreferredTransform
        }
        
        // set new time range in video track
        if videoTracks.count > 0 {
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            let videoTrack = videoTracks.first!
            try compositionVideoTrack?.insertTimeRange(oldTimeRange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack?.scaleTimeRange(oldTimeRange, toDuration: destinationTimeRange)
            
            let videoPreferredTransform = try await videoTrack.load(.preferredTransform)
            compositionVideoTrack?.preferredTransform = videoPreferredTransform
        }
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
    
    
    ///set video size for AVMutableVideoCompositionLayerInstruction
    private func videoCompositionInstructionForTrackWithSizeAndTime(preferredTransform: CGAffineTransform, naturalSize: CGSize, newSize: CGSize,  track: AVAssetTrack, scale: Double, isMirror: Bool) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetInfo = orientationFromTransform(preferredTransform)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        var aspectFillRatio:CGFloat = 1
        if naturalSize.height < naturalSize.width {
            aspectFillRatio = newSize.height / naturalSize.height
        }
        else {
            aspectFillRatio = newSize.width / naturalSize.width
        }
        
        let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
        
        if assetInfo.isPortrait {
           
            let posX = newSize.width/2 - (naturalSize.height * aspectFillRatio)/2
            let posY = newSize.height/2 - (naturalSize.width * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            instruction.setTransform(preferredTransform.concatenating(scaleFactor).concatenating(moveFactor), at: .zero)
            
        } else {
            let posX = newSize.width/2 - (naturalSize.width * aspectFillRatio)/2
            let posY = newSize.height/2 - (naturalSize.height * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            var concat = preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)
            
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
                
            }
            instruction.setTransform(concat, at: .zero)
        }
        

        if isMirror {
            var transform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.translatedBy(x: -newSize.width, y: 0.0)
            instruction.setTransform(transform, at: .zero)
        }
        
        return instruction
    }
    
    
   private func getSizeFromOrientation(newSize: CGSize, videoTrackPreferredTransform: CGAffineTransform) -> CGSize{
        let orientation = self.orientationFromTransform(videoTrackPreferredTransform)
        
        var outputSize = newSize
        if !orientation.isPortrait{
            outputSize.width = newSize.height
            outputSize.height = newSize.width
        }
        print("OutputSize", outputSize)
        return outputSize
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



//func addTracks(to composition: AVMutableComposition, from asset: AVAsset) -> Bool {
//    guard
//        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first,
//        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first,
//        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid),
//        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//    else {
//        return false
//    }
//
//    do {
//        try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: videoTrack, at: CMTime.zero)
//        try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: audioTrack, at: CMTime.zero)
//    } catch {
//        return false
//    }
//
//    return true
//}
//
//
//// создание и добавление текстовых слоев
//func addTextLayers(to composition: AVMutableComposition, with objects: [(text: String, point: CGPoint, timeInterval: TimeInterval)]) -> AVMutableComposition {
//    for object in objects {
//        let text = object.text
//        let point = object.point
//        let timeInterval = object.timeInterval
//
//        let textLayer = createTextLayer(with: text, point: point)
//
//        let parentLayer = createParentLayer(with: textLayer, videoTrack: composition.tracks(withMediaType: AVMediaType.video).first!, naturalSize: composition.naturalSize)
//
//        addAnimation(to: textLayer, with: timeInterval, videoTrack: composition.tracks(withMediaType: AVMediaType.video).first!)
//
//        let instruction = createLayerInstruction(with: composition.tracks(withMediaType: AVMediaType.video).first!, duration: composition.duration)
//
//        let videoComposition = createVideoComposition(with: asset, instruction: instruction, parentLayer: parentLayer, videoTrack: composition.tracks(withMediaType: AVMediaType.video).first!)
//
//        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
//        let layer = createLayer(with: parentLayer, videoComposition: videoComposition, videoTrack: composition.tracks(withMediaType: AVMediaType.video).first!)
//        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: layer, in: composition)
//    }
//
//    return composition
//}
//
//func createTextLayer(with text: String, point: CGPoint) -> CATextLayer {
//    let textLayer = CATextLayer()
//    textLayer.string = text
//    textLayer.font = "Helvetica-Bold" as CFTypeRef
//    textLayer.fontSize = 48
//    textLayer.alignmentMode = .center
//    textLayer.foregroundColor = UIColor.white.cgColor
//    textLayer.backgroundColor = UIColor.clear.cgColor
//    textLayer.frame = CGRect(x: 0, y: 0, width: 600, height: 80)
//    textLayer.position = point
//    return textLayer
//}
//
//func createParentLayer(with textLayer: CATextLayer, videoTrack: AVAssetTrack, naturalSize: CGSize) -> CALayer {
//    let parentLayer = CALayer()
//    let videoLayer = CALayer()
//    parentLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
//    videoLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
//    parentLayer.addSublayer(videoLayer)
//    parentLayer.addSublayer(textLayer)
//    return parentLayer
//}
//
//func addAnimation(to textLayer: CATextLayer, with timeInterval: TimeInterval, videoTrack: AVAssetTrack) {
//    let animation = CABasicAnimation(keyPath: "opacity")
//    animation.fromValue = 1.0
//    animation.toValue = 0.0
//    animation.beginTime = timeInterval + videoTrack.timeRange.start.seconds
//    animation.duration = 1.0
//    animation.fillMode = .forwards
//    animation.isRemovedOnCompletion = false
//    textLayer.add(animation, forKey: "opacity")
//}
//
//
//func createLayerInstruction(with videoTrack: AVAssetTrack, duration: CMTime) -> AVMutableVideoCompositionLayerInstruction {
//    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
//    layerInstruction.setTransform(videoTrack.preferredTransform, at: CMTime.zero)
//    return layerInstruction
//}
//
//func createVideoComposition(with asset: AVAsset, instruction: AVMutableVideoCompositionInstruction, parentLayer: CALayer, videoTrack: AVAssetTrack) -> AVMutableVideoComposition {
//    let videoComposition = AVMutableVideoComposition()
//    videoComposition.instructions = [instruction]
//    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//    videoComposition.renderSize = asset.tracks(withMediaType: AVMediaType.video).first?.naturalSize ?? CGSize.zero
//    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: parentLayer, in: parentLayer)
//    return videoComposition
//}
//
//func createLayer(with parentLayer: CALayer, videoComposition: AVMutableVideoComposition, videoTrack: AVAssetTrack) -> CALayer {
//    let layer = CALayer()
//    layer.frame = CGRect(x: 0, y: 0, width: videoComposition.renderSize.width, height: videoComposition.renderSize.height)
//    layer.addSublayer(parentLayer)
//    return layer
//}
//


//
//class ObservableExporter {
//    
//    var progressTimer: Timer?
//    let session: AVAssetExportSession
//    public let progress: Binding<Double>
//    public var duration: TimeInterval?
//    
//    init(session: AVAssetExportSession, progress: Binding<Double>) {
//        self.session = session
//        self.progress = progress
//    }
//    
//    func export() async throws -> AVAssetExportSession.Status {
//        progressTimer = Timer(timeInterval: 0.1, repeats: true, block: { timer in
//            self.progress.wrappedValue = Double(self.session.progress)
//        })
//        RunLoop.main.add(progressTimer!, forMode: .common)
//        let startDate = Date()
//        await session.export()
//        progressTimer?.invalidate()
//        let endDate = Date()
//        duration = endDate.timeIntervalSince(startDate)
//        if let error = session.error {
//            throw error
//        } else {
//            return session.status
//        }
//    }
//}
