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
    @Published private(set) var finishedAudio: Audio?
    @Published private(set) var timerCount: Timer?
    @Published private(set) var currentRecordTime: TimeInterval = 0

    
    func startRecording(recordMaxTime: Double = 10){
        print("DEBUG:", "startRecording")
        AVAudioSession.sharedInstance().configureRecordAudioSessionCategory()
        
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
            timerCount = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {[weak self] (value) in
                guard let self = self else {return}
                self.currentRecordTime += 0.2
                if self.currentRecordTime >= recordMaxTime{
                    self.stopRecording()
                }
            }
        } catch {
            recordState = .error
            print("Failed to Setup the Recording")
        }
    }
    
    
    func stopRecording(){
        print("DEBUG:", "stopRecording")
        audioRecorder.stop()
        recordState = .empty
        finishedAudio = .init(url: audioRecorder.url, duration: currentRecordTime)
        resetTimer()
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
        self.currentRecordTime = 0
    }
    
    private func removeRecordedAudio(){
        FileManager.default.removefileExists(for: audioRecorder.url)
    }
    
    enum AudioRecordEnum: Int{
        case recording, empty, error
    }
}







