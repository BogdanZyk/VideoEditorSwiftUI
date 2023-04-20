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
                    editorVM.setVideo(url, geo: proxy)
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
    case cut, speed, crop, audio, text, filters, corrections, frames
    
    
    var title: String{
        switch self {
        case .cut: return "Cut"
        case .speed: return "Speed"
        case .crop: return "Crop"
        case .audio: return "Audio"
        case .text: return "Text"
        case .filters: return "Filters"
        case .corrections: return "Corrections"
        case .frames: return "Frames"
        }
    }
    
    var image: String{
        switch self {
        case .cut: return "scissors"
        case .speed: return "timer"
        case .crop: return "crop"
        case .audio: return "waveform"
        case .text: return "t.square.fill"
        case .filters: return "camera.filters"
        case .corrections: return "circle.righthalf.filled"
        case .frames: return "person.crop.artframe"
        }
    }
}



enum EditorState: Int{
    case empty, fullScreen
}


//            ThumbnailsSliderView(curretTime: $videoPlayer.currentTime, loadedState: videoPlayer.loadState){
//                    videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
//            }
