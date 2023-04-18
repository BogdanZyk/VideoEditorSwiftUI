//
//  PlayerHolderView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct PlayerHolderView: View{
    @Binding var isFullScreen: Bool
    @ObservedObject var editorVM: EditorViewModel
    @ObservedObject var videoPlayer: VideoPlayerManager
    var body: some View{
        VStack(spacing: 10) {
            ZStack(alignment: .bottom){
                switch videoPlayer.loadState{
                case .loading:
                    ProgressView()
                case .unknown:
                    Text("Add new video")
                case .failed:
                    Text("Failed to open video")
                case .loaded:
                    PlayerView(player: videoPlayer.player)
                        .onTapGesture {
                            videoPlayer.action()
                        }
                    timelineLabel
                }
            }
            .allFrame()
            playSection
            timeLineControlSection
        }
    }
}

struct PlayerHolderView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView()
            .preferredColorScheme(.dark)
    }
}

extension PlayerHolderView{
    
    
    private var timeLineControlSection: some View{
        TimeLineView(editorVM: editorVM, curretTime: $videoPlayer.currentTime) {
            videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
        }
    }
    
    private var playSection: some View{
        
        Button {
            videoPlayer.action()
        } label: {
            Image(systemName: videoPlayer.isPlaying ? "pause.fill" : "play.fill")
                .imageScale(.medium)
        }
        .buttonStyle(.plain)
        .hCenter()
        .frame(height: 30)
        .overlay(alignment: .trailing) {
            Button {
                withAnimation {
                    isFullScreen.toggle()
                }
            } label: {
                Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .imageScale(.medium)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
    
    
    @ViewBuilder
    private var timelineLabel: some View{
        if let asset = editorVM.asset{
            HStack{
                Text(Int(videoPlayer.currentTime).secondsToTime()) +
                Text(" / ") +
                Text(Int(asset.videoDuration()).secondsToTime())
            }
            .font(.caption2)
            .foregroundColor(.white)
            .frame(width: 80)
            .padding(5)
            .background(Color(.black).opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
            .padding()
        }
    }
}
