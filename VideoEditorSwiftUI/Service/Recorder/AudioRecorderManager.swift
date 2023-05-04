//
//  AudioRecorderManager.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 03.05.2023.
//

import Foundation
import Combine
import AVFoundation


final class AudioRecorderManager: ObservableObject {
    
    private var audioRecorder: AVAudioRecorder!
    
    @Published var recordState: AudioRecordEnum = .empty
    @Published var isLoading: Bool = false
    @Published var uploadURL: URL?
    @Published var toggleColor: Bool = false
    @Published var timerCount: Timer?
    @Published var blinkingCount: Timer?
    @Published var currentRecordTime: Double = 0
    
    
    init(){
        AVAudioSession.sharedInstance().configureRecordAudioSessionCategory()
    }
   
 
    func startRecording(recordMaxTime: Double = 10){
        print("DEBUG:", "startRecording")
        
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let audioCachURL = path.appendingPathComponent("Voice-\(UUID().uuidString).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioCachURL, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            recordState = .recording
            timerCount = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {[weak self] (value) in
                guard let self = self else {return}
                self.currentRecordTime += 0.1
                if self.currentRecordTime >= recordMaxTime{
                    self.stopRecording()
                }
            }
            blinkColor()
            
        } catch {
            recordState = .error
            print("Failed to Setup the Recording")
        }
    }
    
    
    func stopRecording(){
        print("DEBUG:", "stopRecording")
        audioRecorder.stop()
        resetTimer()
        recordState = .empty
        uploadURL = audioRecorder.url
    }
    
    func cancel(){
        print("DEBUG:", "cancel")
        audioRecorder.stop()
        recordState = .empty
        resetTimer()
        removeRecordedAudio()
    }
        
   
    private func resetTimer(){
        timerCount!.invalidate()
        blinkingCount!.invalidate()
        self.currentRecordTime = 0
    }
    
    private func removeRecordedAudio(){
        FileManager.default.removefileExists(for: audioRecorder.url)
    }
    
    private func blinkColor() {
        
        blinkingCount = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (value) in
            self.toggleColor.toggle()
        })
        
    }
}



enum AudioRecordEnum: Int{
    case recording, empty, error
}


extension TimeInterval {
    var minutesSecondsMilliseconds: String {
        String(format: "%02.0f:%02.0f:%02.0f",
               (self / 60).truncatingRemainder(dividingBy: 60),
               truncatingRemainder(dividingBy: 60),
               (self * 100).truncatingRemainder(dividingBy: 100).rounded(.down))
    }
    
    
    var minuteSeconds: String {
        guard self > 0 && self < Double.infinity else {
            return "unknown"
        }
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        
        return String(format: "%0.2d:%0.2d", minutes, seconds)
        
    }
}
