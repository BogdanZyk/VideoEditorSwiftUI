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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    var project: ProjectEntity?
    var selectedVideoURl: URL?
    @State var isFullScreen: Bool = false
    @State var showVideoQualitySheet: Bool = false
    @State var showRecordView: Bool = false
    @StateObject var editorVM = EditorViewModel()
    @StateObject var videoPlayer = VideoPlayerManager()
        
    var body: some View {
        ZStack{
            GeometryReader { proxy in
                VStack(spacing: 0){
                    headerView
                    PlayerHolderView(isFullScreen: $isFullScreen, editorVM: editorVM, videoPlayer: videoPlayer)
                        .frame(height: proxy.size.height / (isFullScreen ?  1.1 : 1.5))
                    ToolsSectionView(videoPlayer: videoPlayer, editorVM: editorVM)
                        .opacity(isFullScreen ? 0 : 1)
                        .padding(.top, 5)
                }
                
                .onAppear{
                    if let selectedVideoURl{
                        videoPlayer.loadState = .loaded(selectedVideoURl)
                        editorVM.setNewVideo(selectedVideoURl, geo: proxy)
                    }
                    
                    if let project, let url = project.videoURL{
                        videoPlayer.loadState = .loaded(url)
                        editorVM.setProject(project, geo: proxy)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                            if let filter = project.filterName{
                                videoPlayer.setFilter(CIFilter(name: filter))
                            }
                        }
                    }
                }
            }
            
            if showVideoQualitySheet, let video = editorVM.currentVideo{
                VideoExporterBottomSheetView(isPresented: $showVideoQualitySheet, video: video)
            }
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all, edges: .top)
        .fullScreenCover(isPresented: $showRecordView) {
            RecordVideoView{ url in
                videoPlayer.loadState = .loaded(url)
            }
        }
        .statusBar(hidden: true)
        .onChange(of: scenePhase) { phase in
            saveProject(phase)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView(selectedVideoURl: URL(string: "file:///Users/bogdanzykov/Library/Developer/CoreSimulator/Devices/86D65E8C-7D49-47AF-A511-BFA631289CB1/data/Containers/Data/Application/52E5EF3C-9E78-4676-B3EA-03BD22CCD09A/Documents/video_copy.mp4"))
    }
}

extension MainEditorView{
    private var headerView: some View{
        HStack{
            Button {
                editorVM.updateProject()
                dismiss()
            } label: {
                Image(systemName: "folder.fill")
            }

            Spacer()
            
            Button {
                showVideoQualitySheet.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up.fill")
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .frame(height: 50)
        .padding(.bottom)
    }
    
    private func saveProject(_ phase: ScenePhase){
        switch phase{
        case .background, .inactive:
            editorVM.updateProject()
        default:
            break
        }
    }
}



