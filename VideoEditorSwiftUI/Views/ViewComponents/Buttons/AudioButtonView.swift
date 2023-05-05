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
    @State private var audioSimples = [Audio.AudioSimple]()
    var body: some View {
        GeometryReader { proxy in
            ZStack{
                Color(.systemGray5)
                if let audio = video.audio{
                    audioButton(proxy, audio)
                }else if recorderManager.recordState == .recording{
                    recordRectangle(proxy)
                }
            }
        }
        .frame(height: 40)
    }
}

struct AudioButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AudioButtonView(video: Video.mock, isSelectedTrack: .constant(false), recorderManager: AudioRecorderManager())
    }
}


extension AudioButtonView{
    
    

    
    private func recordRectangle(_ proxy: GeometryProxy) -> some View{
        let width = getWidthFromDuration(allWight: proxy.size.width, currentDuration: recorderManager.currentRecordTime, totalDuration: video.totalDuration)
        return RoundedRectangle(cornerRadius: 8)
            .fill(Color.red.opacity(0.5))
            .frame(width: width)
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

    private func getWidthFromDuration(allWight: CGFloat, currentDuration: Double, totalDuration: Double) -> CGFloat{
        return (allWight / totalDuration) * currentDuration
    }
}
