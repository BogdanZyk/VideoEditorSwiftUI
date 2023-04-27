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
    
    var scale: CGFloat{
        isFullScreen ? 1.4 : 1
    }

    var body: some View{
        VStack(spacing: 6) {
            ZStack(alignment: .bottom){
                switch videoPlayer.loadState{
                case .loading:
                    ProgressView()
                case .unknown:
                    Text("Add new video")
                case .failed:
                    Text("Failed to open video")
                case .loaded:
                    playerCropView
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

    private var playerCropView: some View{
        Group{
            if let video = editorVM.currentVideo{
                GeometryReader { proxy in
                    CropView(
                        originalSize: .init(width: video.frameSize.width * scale, height: video.frameSize.height * scale),
                        rotation: editorVM.currentVideo?.rotation,
                        isMirror: editorVM.currentVideo?.isMirror ?? false,
                        isActiveCrop: editorVM.selectedTools == .crop) {
                            ZStack{
                                editorVM.frames.frameColor
                                PlayerView(player: videoPlayer.player)
                                    .scaleEffect(editorVM.frames.scale)
                            }
                            
                            //                            .onTapGesture {
                            //                                videoPlayer.action(video)
                            //                            }
                        }
                        .allFrame()
                        .onAppear{
                            Task{
                                guard let size = await editorVM.currentVideo?.asset.adjustVideoSize(to: proxy.size) else {return}
                             editorVM.currentVideo?.frameSize = size
                         }
                     }
                }
            }
            timelineLabel
        }
    }
}

extension PlayerHolderView{
    
    
    @ViewBuilder
    private var timeLineControlSection: some View{
        if let video = editorVM.currentVideo{
            TimeLineView(video: video, curretTime: $videoPlayer.currentTime) {
                videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
            }
        }
        
    }
    
    private var playSection: some View{
        
        Button {
            if let video = editorVM.currentVideo{
                videoPlayer.action(video)
            }
        } label: {
            Image(systemName: videoPlayer.isPlaying ? "pause.fill" : "play.fill")
                .imageScale(.medium)
        }
        .buttonStyle(.plain)
        .hCenter()
        .frame(height: 30)
        .overlay(alignment: .trailing) {
            Button {
                videoPlayer.pause()
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
        if let video = editorVM.currentVideo{
            HStack{
                Text((videoPlayer.currentTime - video.rangeDuration.lowerBound)  .formatterTimeString()) +
                Text(" / ") +
                Text(Int(video.totalDuration).secondsToTime())
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
