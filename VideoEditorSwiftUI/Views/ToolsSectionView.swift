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
    @State var toolState: ToolEnum?
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        ZStack{
            LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                ForEach(ToolEnum.allCases, id: \.self) { tool in
                    ToolButtonView(label: tool.title, image: tool.image) {
                        toolState = tool
                    }
                }
            }
            .padding()
            .opacity(toolState != nil ? 0 : 1)
            if let toolState{
                bottomSheet(toolState)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeIn(duration: 0.15), value: toolState)
    }
}

struct ToolsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView()
    }
}


extension ToolsSectionView{
    
    
    private func bottomSheet(_ state: ToolEnum) -> some View{
        ZStack(alignment: .bottom){
            VStack{
                Spacer()
                switch state {
                case .cut:
                    ThumbnailsSliderView(curretTime: $videoPlayer.currentTime, video: $editorVM.currentVideo) {
                        videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
                    }
                case .speed:
                    EmptyView()
                case .crop:
                    EmptyView()
                case .audio:
                    EmptyView()
                case .text:
                    EmptyView()
                case .filters:
                    EmptyView()
                }
                
                Spacer()
                Text(state.title)
                    .font(.headline)
            }
        }
        .allFrame()
        .background(Color(.systemGray6))
        .overlay(alignment: .topLeading) {
            Button {
                toolState = nil
            } label: {
                Image(systemName: "chevron.down")
                    .imageScale(.small)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 5))
            }
            .padding()
        }
    }
}
