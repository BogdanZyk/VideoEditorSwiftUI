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
    
    @Published private(set) var recordState: AudioRecordEnum = .empty
    @Published private(set) var uploadURL: URL?
    @Published private(set) var toggleColor: Bool = false
    @Published private(set) var timerCount: Timer?
    @Published private(set) var blinkingCount: Timer?
    @Published private(set) var currentRecordTime: TimeInterval = 0
    
    
    init(){
        AVAudioSession.sharedInstance().configureRecordAudioSessionCategory()
    }
   
 
    func startRecording(recordMaxTime: Double = 10){
        print("DEBUG:", "startRecording")
        
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let audioURL = path.appendingPathComponent("video-record.m4a")
        FileManager.default.removefileExists(for: audioURL)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
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
    
    enum AudioRecordEnum: Int{
        case recording, empty, error
    }
}







