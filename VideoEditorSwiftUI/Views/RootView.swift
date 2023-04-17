//
//  RootView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//
import AVKit
import SwiftUI
import PhotosUI

struct RootView: View {
    @State var showRecordView: Bool = false
    @StateObject var rootVM = RootViewModel()
    @StateObject var videoPlayer = VideoPlayerManager()
    var body: some View {
        GeometryReader { proxy in
            VStack{
                videoPlayerSection
                    .frame(height: proxy.size.height / 1.8)
                
                
               
                ThumbnailsSliderView(curretTime: $videoPlayer.currentTime, loadedState: videoPlayer.loadState){
                        videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
                }
                
                PhotosPicker("Select video", selection: $videoPlayer.selectedItem, matching: .videos)
                Button("Record video") {
                    showRecordView.toggle()
                }
            }
            
        }
        .onChange(of: videoPlayer.selectedItem) { newValue in
            Task{
                await videoPlayer.loadVideoItem(newValue)
            }
        }
        .fullScreenCover(isPresented: $showRecordView) {
            RecordVideoView{ url in
                videoPlayer.loadState = .loaded(url)
            }
        }
        
        .onChange(of: videoPlayer.loadState) { type in
            switch type{
            case .loaded(let url):
                rootVM.setAsset(url)
            default:
                break
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

extension RootView{
    @ViewBuilder
    private var videoPlayerSection: some View{
        ZStack{
            Color(.systemGray5)
            switch videoPlayer.loadState{
            case .unknown:
                EmptyView()
            case .loading:
                ProgressView()
            case .failed:
                Text("Failed to open video")
            case .loaded:
                VideoPlayer(player: videoPlayer.player)
            }
        }
    }
}
