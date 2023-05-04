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
    @Binding var isSelectedTrack: Bool
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
                        stopButton(proxy)
                    }
                }
            }
            .onChange(of: recorderManager.finishedAudio) { newValue in
                guard let newValue else { return }
                onRecorded(newValue)
                state = .empty
            }
        }
        .frame(height: 40)
        .onChange(of: recorderManager.currentRecordTime) { newValue in
            if newValue > 0{
                onRecordTime(newValue)
            }
        }
    }
}

struct AudioButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AudioButtonView(video: Video.mock, isSelectedTrack: .constant(false), recorderManager: AudioRecorderManager(), onRecorded: {_ in}, onRecordTime: {_ in})
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
    
    private func stopButton(_ proxy: GeometryProxy) -> some View{
        let width = getWidthFromDuration(allWight: proxy.size.width, currentDuration: recorderManager.currentRecordTime, totalDuration: video.totalDuration)
        return  HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.5))
                .frame(width: width)
            Image(systemName: "stop.fill")
                .foregroundColor(.red)
                .onTapGesture {
                    state = .empty
                    recorderManager.stopRecording()
                }
        }
        .hLeading()
        .animation(.easeIn, value: recorderManager.currentRecordTime)
    }
    
    private func audioButton(_ proxy: GeometryProxy, _ audio: Audio) -> some View{
        let width = getWidthFromDuration(allWight: proxy.size.width, currentDuration: audio.duration, totalDuration: video.totalDuration)
        return RoundedRectangle(cornerRadius: 8)
            .fill(Color.red.opacity(0.5))
            .overlay {
                ZStack{
                    if !isSelectedTrack{
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(lineWidth: 2)
                    }
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
            .onTapGesture {
                isSelectedTrack.toggle()
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
    
    private func getWidthFromDuration(allWight: CGFloat, currentDuration: Double, totalDuration: Double) -> CGFloat{
        return (allWight / totalDuration) * currentDuration
    }
}
