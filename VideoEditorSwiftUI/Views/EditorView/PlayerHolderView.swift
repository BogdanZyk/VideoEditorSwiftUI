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
    @ObservedObject var textEditor: TextEditorViewModel
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
                                ZStack{
                                    PlayerView(player: videoPlayer.videoPlayer)
                                    TextOverlayView(currentTime: videoPlayer.currentTime, viewModel: textEditor,  disabledMagnification: isFullScreen)
                                        .scaleEffect(scale)
                                        .disabled(isFullScreen)
                                }
                                .scaleEffect(editorVM.frames.scale)
                            }
                        }
                        .allFrame()
                        .onAppear{
                            Task{
                                guard let size = await editorVM.currentVideo?.asset.adjustVideoSize(to: proxy.size) else {return}
                             editorVM.currentVideo?.frameSize = size
                                editorVM.currentVideo?.geometrySize = proxy.size
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


struct PlayerControl: View{
    @Binding var isFullScreen: Bool
    @ObservedObject var recorderManager: AudioRecorderManager
    @ObservedObject var editorVM: EditorViewModel
    @ObservedObject var videoPlayer: VideoPlayerManager
    @ObservedObject var textEditor: TextEditorViewModel
    var body: some View{
        VStack(spacing: 6) {
            playSection
            timeLineControlSection
        }
    }
    
    
    @ViewBuilder
    private var timeLineControlSection: some View{
        if let video = editorVM.currentVideo{
            TimeLineView(
                recorderManager: recorderManager,
                currentTime: $videoPlayer.currentTime,
                isSelectedTrack: $editorVM.isSelectVideo,
                viewState: editorVM.selectedTools?.timeState ?? .empty,
                video: video, textInterval: textEditor.selectedTextBox?.timeRange) {
                    videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
                } onChangeTextTime: { textTime in
                    textEditor.setTime(textTime)
                } onSetAudio: { audio in
                    editorVM.setAudio(audio)
                    videoPlayer.setAudio(audio.url)
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
}
