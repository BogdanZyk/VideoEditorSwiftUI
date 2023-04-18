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
    @State var isFullScreen: Bool = false
    @State var showRecordView: Bool = false
    @StateObject var rootVM = EditorViewModel()
    @StateObject var videoPlayer = VideoPlayerManager()
        
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0){
                headerView
                PlayerHolderView(isFullScreen: $isFullScreen, editorVM: rootVM, videoPlayer: videoPlayer)
                    .frame(height: proxy.size.height / (isFullScreen ?  1.05 : 1.4))
                    ToolsSectionView()
                        .opacity(isFullScreen ? 0 : 1)
                        .padding()
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
        .onChange(of: videoPlayer.loadState) { type in
            switch type{
            case .loaded(let url):
                rootVM.setAsset(url)
            default:
                break
            }
        }
        .overlay(alignment: .topLeading) {
            
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView()
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




enum ToolEnum: Int, CaseIterable{
    case cut, speed, crop, audio, text, filters
    
    
    var title: String{
        switch self {
        case .cut: return "Cut"
        case .speed: return "Speed"
        case .crop: return "Crop"
        case .audio: return "Audio"
        case .text: return "Text"
        case .filters: return "Filters"
        }
    }
    
    var image: String{
        switch self {
        case .cut: return "scissors"
        case .speed: return "scissors"
        case .crop: return "scissors"
        case .audio: return "scissors"
        case .text: return "scissors"
        case .filters: return "scissors"
        }
    }
}



enum EditorState: Int{
    case empty, fullScreen
}


//            ThumbnailsSliderView(curretTime: $videoPlayer.currentTime, loadedState: videoPlayer.loadState){
//                    videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
//            }
