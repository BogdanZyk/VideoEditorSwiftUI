//
//  AudioButtonView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 04.05.2023.
//

import SwiftUI
import AVKit

struct AudioButtonView: View {
    var video: Video
    @ObservedObject var recorderManager: AudioRecorderManager
    @State private var timeRemaining = 3
    @State private var timer: Timer? = nil
    @State private var state: StateEnum = .empty
    @State private var audioSimples = [Audio.AudioSimple]()
    let onRecorded: (Audio) -> Void
    let onRecordTime: (Double) -> Void
    var body: some View {
        GeometryReader { proxy in
            ZStack{
                Color(.systemGray5)
                if let audio = video.audio{
                    audioButton(proxy, audio)
                }else{
                    switch state {
                    case .empty:
                        recordButton
                    case .timer:
                        timerButton
                    case .record:
                        stopButton
                    }
                }
            }
            .onChange(of: recorderManager.finishedAudio) { newValue in
                guard let newValue else { return }
                onRecorded(newValue)
            }
        }
        .frame(height: 40)
        .onChange(of: recorderManager.currentRecordTime) { newValue in
            onRecordTime(newValue)
        }
    }
}

struct AudioButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AudioButtonView(video: Video.mock, recorderManager: AudioRecorderManager(), onRecorded: {_ in}, onRecordTime: {_ in})
    }
}


extension AudioButtonView{
    
    
    private var recordButton: some View{
        Button {
            state = .timer
            startTimer()
        } label: {
            Image(systemName: "mic.fill")
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .hLeading()
    }
    
    private var timerButton: some View{
        Text("\(timeRemaining)")
            .font(.subheadline.bold())
            .foregroundColor(.red)
            .onTapGesture {
                state = .empty
                stopTimer()
            }
            .padding(.horizontal)
            .hLeading()
    }
    
    private var stopButton: some View{
        Image(systemName: "stop.fill")
            .foregroundColor(.red)
            .onTapGesture {
                state = .empty
                recorderManager.stopRecording()
            }
            .scaleEffect(recorderManager.toggleColor ? 0.9 : 1)
            .padding(.horizontal)
            .hLeading()
    }
    
    private func audioButton(_ proxy: GeometryProxy, _ audio: Audio) -> some View{
        let sizePerSec = proxy.size.width / video.totalDuration
        let width = sizePerSec * audio.duration
        return RoundedRectangle(cornerRadius: 8)
            .fill(Color.red.opacity(0.5))
            .overlay {
                ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(lineWidth: 2)
                    HStack(spacing: 1){
                        ForEach(audioSimples) { simple in
                            Capsule()
                                .fill(.white)
                                .frame(width: 2, height: simple.size)
                        }
                    }
                }
            }
            .frame(width: width)
            .hLeading()
            .onAppear{
                audioSimples = audio.createSimples(width)
            }
    }
    
    enum StateEnum: Int{
        case empty, timer, record
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
