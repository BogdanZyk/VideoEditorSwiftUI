//
//  CameraPreviewView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import SwiftUI
import AVFoundation



final class CameraManager: NSObject, ObservableObject{
    
    enum Status{
        case unconfigurate
        case configurate
        case unauthorized
        case faild
    }
    
    @Published var error: CameraError?
    @Published var session = AVCaptureSession()
    @Published var finalURL: URL?
    @Published var recordedDuration: Double = .zero
    @Published var cameraPosition: AVCaptureDevice.Position = .front
    
    let maxDuration: Double = 100 // sec
    private var timer: Timer?
    private let sessionQueue = DispatchQueue(label: "com.VideoEditorSwiftUI")
    private let videoOutput = AVCaptureMovieFileOutput()
    private var status: Status = .unconfigurate
    
    var isRecording: Bool{
        videoOutput.isRecording
    }
    
    override init(){
        super.init()
        config()
    }
    
    private func config(){
        checkPermissions()
        sessionQueue.async {
            self.configCaptureSession()
            self.session.startRunning()
        }
    }
    
    func controllSession(start: Bool){
        guard status == .configurate else {
            config()
            return
        }
        sessionQueue.async {
            if start{
                if !self.session.isRunning{
                    self.session.startRunning()
                }
            }else{
                self.session.stopRunning()
            }
        }
    }
    
    private func setError(_ error: CameraError?){
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    ///Check user permissions
    private func checkPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { aurhorized in
                if !aurhorized{
                    self.status = .unauthorized
                    self.setError(.deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            setError(.restrictedAuthorization)
        case .denied:
            status = .unauthorized
            setError(.deniedAuthorization)
            
        case .authorized: break
        @unknown default:
            status = .unauthorized
            setError(.unknowAuthorization)
        }
    }
    
    ///Configuring a session and adding video, audio input and adding video output
    private func configCaptureSession(){
        guard status == .unconfigurate else {
            return
        }
        session.beginConfiguration()
        
        session.sessionPreset = .hd1280x720
        
        let device = getCameraDevice(for: .back)
        let audioDevice = AVCaptureDevice.default(for: .audio)
        
        guard let camera = device, let audio = audioDevice else {
            setError(.cameraUnavalible)
            status = .faild
            return
        }
        
        do{
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            let audioInput = try AVCaptureDeviceInput(device: audio)
            
            if session.canAddInput(cameraInput) && session.canAddInput(audioInput){
                session.addInput(audioInput)
                session.addInput(cameraInput)
            }else{
                setError(.cannotAddInput)
                status = .faild
                return
            }
        }catch{
            setError(.createCaptureInput(error))
            status = .faild
            return
        }
        
        if session.canAddOutput(videoOutput){
            session.addOutput(videoOutput)
        }else{
            setError(.cannotAddInput)
            status = .faild
            return
        }
        
        session.commitConfiguration()
    }
    
    
   private func getCameraDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func stopRecord(){
        print("stop")
        timer?.invalidate()
        videoOutput.stopRecording()
    }
    
    func startRecording(){
        ///Temporary URL for recording Video
        let tempURL = NSTemporaryDirectory() + "\(Date().ISO8601Format()).mov"
        print(tempURL)
        videoOutput.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        startTimer()
    }
    
//    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
//             queue: DispatchQueue){
//        sessionQueue.async {
//            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
//        }
//    }
    
    
}



extension CameraManager{
    
    private func onTimerFires(){
        
        if recordedDuration <= maxDuration && videoOutput.isRecording{
            print("🟢 RECORDING")
            recordedDuration += 1
        }
        if recordedDuration >= maxDuration && videoOutput.isRecording{
            stopRecord()
        }
    }
    
    private func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
                self?.onTimerFires()
            }
        }
    }
}



extension CameraManager: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL)
        if let error{
            self.error = .outputError(error)
        }else{
            self.finalURL = outputFileURL
        }
    }
    
    
}



enum CameraError: Error{
    case deniedAuthorization
    case restrictedAuthorization
    case unknowAuthorization
    case cameraUnavalible
    case cannotAddInput
    case createCaptureInput(Error)
    case outputError(Error)
}


extension Int {

    func secondsToTime() -> String {

        let (m,s) = ((self % 3600) / 60, (self % 3600) % 60)
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"

        return "\(m_string):\(s_string)"
    }
}

extension Double{
    
    func formatterTimeString() -> String{
        let minutes = Int(self / 60)
          let seconds = Int(self.truncatingRemainder(dividingBy: 60))
          let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 10)
          return "\(minutes):\(String(format: "%02d", seconds)).\(milliseconds)"
    }
    
}
