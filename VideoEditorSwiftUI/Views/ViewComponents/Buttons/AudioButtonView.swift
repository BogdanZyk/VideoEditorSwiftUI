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
    let onRecorded: (URL) -> Void
    let onRecord: (Bool) -> Void
    var body: some View {
        GeometryReader { proxy in
            ZStack{
                Color(.systemGray5)
                if let audio = video.audioAsset{
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
            .onChange(of: recorderManager.uploadURL) { newValue in
                guard let newValue else { return }
                onRecorded(newValue)
            }
        }
        .frame(height: 40)
    }
}

struct AudioButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AudioButtonView(video: Video.mock, recorderManager: AudioRecorderManager(), onRecorded: {_ in}, onRecord: {_ in})
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
            .foregroundColor(.red)
            .onTapGesture {
                state = .empty
                stopTimer()
            }
    }
    
    private var stopButton: some View{
        Image(systemName: "stop.fill")
            .foregroundColor(.red)
            .onTapGesture {
                state = .empty
                recorderManager.stopRecording()
                onRecord(false)
            }
    }
    
    private func audioButton(_ proxy: GeometryProxy, _ asset: AVAsset) -> some View{
        let simplesCount = Int(proxy.size.width / 3)
        let sizePerSec = proxy.size.width / video.totalDuration
        return RoundedRectangle(cornerRadius: 8)
            .fill(Color.red.opacity(0.5))
            .overlay {
                ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(lineWidth: 2)
                    HStack(spacing: 1){
                        ForEach(0...simplesCount, id: \.self) { index in
                            Capsule()
                                .fill(.white)
                                .frame(width: 2, height: 25)
                        }
                    }
                }
            }
            //.frame(width: sizePerSec * asset.duration.seconds)
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
                onRecord(true)
            }
        }
    }
    
    private func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
}
