//
//  RecorderButtonView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 05.05.2023.
//

import SwiftUI

struct RecorderButtonView: View {
    var video: Video
    @ObservedObject var recorderManager: AudioRecorderManager
    @State private var timeRemaining = 3
    @State private var timer: Timer? = nil
    @State private var state: StateEnum = .empty
    let onRecorded: (Audio) -> Void
    let onRecordTime: (Double) -> Void
    
    private var isSetAudio: Bool{
        video.audio != nil
    }
    
    var body: some View {
        ZStack{
            switch state {
            case .empty:
                if isSetAudio{}
                recordButton
            case .timer:
                timerButton
            case .record:
                stopButton
            }
        }
        .opacity(isSetAudio ? 0 : 1)
        .disabled(isSetAudio)
        .onChange(of: recorderManager.finishedAudio) { newValue in
            guard let newValue else { return }
            onRecorded(newValue)
            state = .empty
        }
        .onChange(of: recorderManager.currentRecordTime) { newValue in
            if newValue > 0{
                onRecordTime(newValue)
            }
        }
    }
}

struct RecorderButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RecorderButtonView(video: Video.mock, recorderManager: AudioRecorderManager(), onRecorded: {_ in}, onRecordTime: {_ in})
    }
}

extension RecorderButtonView{
    
    
    enum StateEnum: Int{
        case empty, timer, record
    }
    
    
    private var recordButton: some View{
        Button {
            state = .timer
            startTimer()
        } label: {
            Image(systemName: "mic.fill")
                .foregroundColor(.white)
        }
    }
    
    private var timerButton: some View{
        Text("\(timeRemaining)")
            .font(.subheadline.bold())
            .foregroundColor(.red)
            .onTapGesture {
                state = .empty
                stopTimer()
            }
    }
    
    private var stopButton:  some View{
        Image(systemName: "stop.fill")
            .foregroundColor(.red)
            .onTapGesture {
                state = .empty
                recorderManager.stopRecording()
            }
    }
    
    
    private func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            timeRemaining -= 1
            if timeRemaining == 0{
                state = .record
                stopTimer()
                recorderManager.startRecording(recordMaxTime: video.totalDuration)
            }
        }
    }
    
    private func stopTimer(){
        timeRemaining = 3
        timer?.invalidate()
        timer = nil
    }
}
