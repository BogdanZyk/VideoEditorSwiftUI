//
//  CameraManager2.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import SwiftUI
import AVFoundation



final class CameraManager2: NSObject, ObservableObject{

    @Published var alert: Bool = false
    @Published var showCameraView: Bool = false
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var captureSession = AVCaptureSession()
    @Published var output = AVCaptureMovieFileOutput()
    
    @Published var cameraPosition: AVCaptureDevice.Position = .front
    @Published var recordedDuration: CGFloat = .zero
    @Published var maxDuration: CGFloat = 60
    @Published var finalURL: URL?
    @Published var isPermissions: Bool = false
    
    let renderSize = CGSize(width: 480, height: 480)
    private var exportPreset = AVAssetExportPreset1280x720
    
    private var recordsURl = [URL]()
    
    private var timer: Timer?
    
    private var stopInitiatorType: Initiator = .empty
    

    
    func checkPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUp()
            isPermissions = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status{
                    self.setUp()
                }
                DispatchQueue.main.async {
                    self.isPermissions = status
                }
            }
        case .denied:
            alert.toggle()
        default:
            break
        }
    }
    
    func setUp(){
        do{
            
            self.captureSession.beginConfiguration()
            
            guard let cameraDevice = cameraWithPosition(position: .front),
                  let audioDevice = getAudioDevice() else {return}
            
            let cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
            
            if captureSession.canAddInput(cameraInput) && captureSession.canAddInput(audioInput){
                captureSession.addInput(cameraInput)
                captureSession.addInput(audioInput)
            }

            if captureSession.canAddOutput(output){
                captureSession.addOutput(output)
            }
            
            captureSession.commitConfiguration()
            
            startCaptureSession()
    
        }
        catch{
            print(error.localizedDescription)
        }
    }
        
    func startRecording(){
        //MARK: - Temporary URL for recording Video
        let tempURL = NSTemporaryDirectory() + "\(Date().ISO8601Format()).mov"
        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        startTimer()
    }
    
    func stopRecording(for initiator: Initiator){
        stopInitiatorType = initiator
        output.stopRecording()
    }
    
    func resetAll(){
        timer?.invalidate()
        timer = nil
        output.stopRecording()
        captureSession.stopRunning()
        preview = nil
        recordedDuration = .zero
        recordsURl.removeAll()
        finalURL = nil
    }
    
    

    

   private func startCaptureSession() {

        let group = DispatchGroup()

        if !captureSession.isRunning {

            group.enter()

            DispatchQueue.global(qos: .default).async {
                [weak self] in

                self?.captureSession.startRunning()
                group.leave()

                group.notify(queue: .main) {
                    self?.preview = AVCaptureVideoPreviewLayer(session: self!.captureSession)
                    self?.preview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                }
            }
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }

    func getAudioDevice() -> AVCaptureDevice?{
        let audioDevice = AVCaptureDevice.default(for: .audio)
        return audioDevice
    }

    
    
}



extension CameraManager2: AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error{
            print(error.localizedDescription)
            return
        }
        
        self.recordsURl.append(outputFileURL)
        print(stopInitiatorType.rawValue)
        
        if recordsURl.count != 0 && (stopInitiatorType == .user || stopInitiatorType == .auto){
            let assets = recordsURl.compactMap({AVURLAsset(url: $0)})
            
            mergeVideos(assets: assets) {[weak self] exporter in
                guard let self = self else {return}
                exporter.exportAsynchronously {
                    if exporter.status == .failed{
                        print(exporter.error?.localizedDescription ?? "Error Exporter failed")
                    }else{
                        if let finalURL = exporter.outputURL{
                            DispatchQueue.main.async {
                                self.finalURL = finalURL
                                self.stopInitiatorType = .empty
                                print("Finished merge url", finalURL)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //merge videos assets in one video with format .mp4
    private func mergeVideos(assets: [AVURLAsset], completion: @escaping (_ exporter: AVAssetExportSession) -> ()){
        let composition = AVMutableComposition()
        var lastTime: CMTime = .zero
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}
        
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}
        
        for asset in assets {
            do{
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: asset.tracks(withMediaType: .video)[0], at: lastTime)
                if !asset.tracks(withMediaType: .audio).isEmpty{
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: lastTime)
                }
            }
            catch{
                print(error.localizedDescription)
            }
            
            lastTime = CMTimeAdd(lastTime, asset.duration)
        }
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: exportPreset) else {return}
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "\(Date().ISO8601Format()).mp4")
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.outputURL = tempUrl
        exporter.videoComposition = prepairVideoComposition(videoTrack, lastTime: lastTime)
        completion(exporter)
    }
    
    // bringing back to original transform
    private func prepairVideoComposition(_ videoTrack: AVMutableCompositionTrack, lastTime: CMTime) -> AVMutableVideoComposition{
        let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        //transform video
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: 90.degreesToRadians)
        let scaleFit = self.renderSize.width / videoTrack.naturalSize.height
        transform = transform.scaledBy(x: scaleFit, y: scaleFit)
        transform = transform.translatedBy(x: -renderSize.height, y: -videoTrack.naturalSize.height)
        layerInstructions.setTransform(transform, at: .zero)
        
        let instrictions = AVMutableVideoCompositionInstruction()
        instrictions.timeRange = CMTimeRange(start: .zero, end: lastTime)
        instrictions.layerInstructions = [layerInstructions]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = .init(width: renderSize.width, height: renderSize.height)
        videoComposition.instructions = [instrictions]
        //fps
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        return videoComposition
    }
    
}

//MARK: - Switch camera
extension CameraManager2{
    
    
    func switchCameraAndStart(completion: @escaping () -> Void){
        stopRecording(for: .onSwitch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.switchCamera()
            self.startRecording()
            completion()
        }
    }
    
   private func switchCamera() {
        guard let currDevicePos = (captureSession.inputs.first as? AVCaptureDeviceInput)?.device.position
        else { return }
        
        //Indicate that some changes will be made to the session
        captureSession.beginConfiguration()
        
        //Get new input
        guard let newCamera = cameraWithPosition(position: (currDevicePos == .back) ? .front : .back ),
              let newAudio = getAudioDevice()
        else {
            print("ERROR: Issue in cameraWithPosition() method")
            return
        }
        
        do {
            let aududioInput = try AVCaptureDeviceInput(device: newAudio)
            let newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            
            //remove all inputs in inputs array!
            while captureSession.inputs.count > 0 {
                captureSession.removeInput(captureSession.inputs[0])
            }
            
            captureSession.addInput(newVideoInput)
            captureSession.addInput(aududioInput)
            
        } catch {
            print("Error creating capture device input: \(error.localizedDescription)")
        }
        
        //Commit all the configuration changes at once
        captureSession.commitConfiguration()
    }
}

//MARK: - Timer

extension CameraManager2{
    
    private func onTimerFires(){
        
        if recordedDuration <= maxDuration && output.isRecording{
            print("🟢 RECORDING")
            recordedDuration += 1
        }
        if recordedDuration >= maxDuration && output.isRecording{
            print("Auto stop")
            stopRecording(for: .auto)
            timer?.invalidate()
            timer = nil
        }
    }

    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
                self?.onTimerFires()
            }
        }
    }
}

extension CameraManager2{
    enum Initiator: Int{
        case user, auto, onSwitch, empty
    }
}



extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
