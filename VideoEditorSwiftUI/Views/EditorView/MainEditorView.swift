//
//  MainEditorView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//
import AVKit
import SwiftUI
import PhotosUI

struct MainEditorView: View {
    var videoURl: URL?
    @State var isFullScreen: Bool = false
    @State var showRecordView: Bool = false
    @StateObject var editorVM = EditorViewModel()
    @StateObject var videoPlayer = VideoPlayerManager()
        
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0){
                headerView
                PlayerHolderView(isFullScreen: $isFullScreen, editorVM: editorVM, videoPlayer: videoPlayer)
                    .frame(height: proxy.size.height / (isFullScreen ?  1.05 : 1.45))
                ToolsSectionView(videoPlayer: videoPlayer, editorVM: editorVM)
                    .opacity(isFullScreen ? 0 : 1)
                    .padding(.top)
            }
            .onChange(of: videoPlayer.loadState) { type in
                switch type{
                case .loaded(let url):
                    Task{
                        await editorVM.setVideo(url, geo: proxy)
                    }
                default:
                    break
                }
            }
        }
        .background(Color.black)
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
        .onAppear{
            if let videoURl{
                videoPlayer.loadState = .loaded(videoURl)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView(videoURl: URL(string: "file:///Users/bogdanzykov/Library/Developer/CoreSimulator/Devices/86D65E8C-7D49-47AF-A511-BFA631289CB1/data/Containers/Data/Application/52E5EF3C-9E78-4676-B3EA-03BD22CCD09A/Documents/video_copy.mp4"))
    }
}

extension MainEditorView{
    private var headerView: some View{
        HStack{
            PhotosPicker(selection: $videoPlayer.selectedItem, matching: .videos) {
                Image(systemName: "plus")
            }
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.bottom)
    }
}



