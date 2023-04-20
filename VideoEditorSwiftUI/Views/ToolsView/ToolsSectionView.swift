//
//  ToolsSectionView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI
import AVKit

struct ToolsSectionView: View {
    @ObservedObject var videoPlayer: VideoPlayerManager
    @ObservedObject var editorVM: EditorViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        ZStack{
            LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                ForEach(editorVM.tools) { model in
                    ToolButtonView(label: model.tool.title, image: model.tool.image, isChange: model.isChange) {
                        editorVM.selectedTools = model
                    }
                }
            }
            .padding()
            .opacity(editorVM.selectedTools != nil ? 0 : 1)
            if let toolState = editorVM.selectedTools, let video = editorVM.currentVideo{
                bottomSheet(toolState, video)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeIn(duration: 0.15), value: editorVM.selectedTools)
    }
}

struct ToolsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView()
    }
}


extension ToolsSectionView{
    
    
    private func bottomSheet(_ model: ToolsModel, _ video: Video) -> some View{
        ZStack(alignment: .bottom){
            VStack{
                Spacer()
                switch model.tool {
                case .cut:
                    ThumbnailsSliderView(curretTime: $videoPlayer.currentTime, video: $editorVM.currentVideo, isChangeState: editorVM.selectedTools?.isChange) {
                        videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
                        editorVM.setToolIsChange(true)
                    }
                case .speed:
                    VideoSpeedSlider(value: Double(video.rate), isChangeState: editorVM.selectedTools?.isChange) {rate in
                        videoPlayer.pause()
                        editorVM.udateRate(rate: rate)
                        editorVM.setToolIsChange(true)
                    }
                case .crop:
                    EmptyView()
                case .audio:
                    EmptyView()
                case .text:
                    EmptyView()
                case .filters:
                    EmptyView()
                case .corrections:
                    EmptyView()
                case .frames:
                    EmptyView()
                }
                
                Spacer()
                Text(model.tool.title)
                    .font(.headline)
            }
        }
        .allFrame()
        .background(Color(.systemGray6))
        .overlay(alignment: .topLeading) {
            HStack {
                Button {
                    editorVM.selectedTools = nil
                } label: {
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 5))
                }
                Spacer()
                Button {
                    editorVM.reset()
                } label: {
                    Text("Reset")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
    }
}


