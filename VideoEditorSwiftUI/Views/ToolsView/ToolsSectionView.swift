//
//  ToolsSectionView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI
import AVKit

struct ToolsSectionView: View {
    @StateObject var filtersVM = FiltersViewModel()
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
                ForEach(ToolEnum.allCases, id: \.self) { tool in
                    ToolButtonView(label: tool.title, image: tool.image, isChange: editorVM.currentVideo?.isAppliedTool(for: tool) ?? false) {
                        editorVM.selectedTools = tool
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
        .onChange(of: editorVM.currentVideo){ newValue in
            if let image = newValue?.thumbnailsImages.first?.image{
                filtersVM.loadFilters(for: image)
            }
        }
    }
}

struct ToolsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView(selectedVideoURl: Video.mock.url)
    }
}


extension ToolsSectionView{
    
    @ViewBuilder
    private func bottomSheet(_ tool: ToolEnum, _ video: Video) -> some View{
        
        let isAppliedTool = video.isAppliedTool(for: tool)
        
        VStack(spacing: 5){
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
                if tool != .filters{
                    Button {
                        editorVM.reset()
                    } label: {
                        Text("Reset")
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            switch tool {
                
            case .cut:
                ThumbnailsSliderView(curretTime: $videoPlayer.currentTime, video: $editorVM.currentVideo, isChangeState: isAppliedTool) {
                    videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
                    editorVM.setTools()
                }
            case .speed:
                VideoSpeedSlider(value: Double(video.rate), isChangeState: isAppliedTool) {rate in
                    videoPlayer.pause()
                    editorVM.updateRate(rate: rate)
                }
            case .crop:
                
                CropSheetView(editorVM: editorVM)
                
            case .audio:
                EmptyView()
            case .text:
                EmptyView()
            case .filters:
                FiltersView(selectedFilterName: video.filterName, viewModel: filtersVM) { filter in
                    if let filter{
                        videoPlayer.setFilter(filter)
                    }else{
                        videoPlayer.removeFilter()
                    }
                    editorVM.setFilter(filter)
                }
                .padding(.top)
            case .corrections:
                EmptyView()
            case .frames:
                EmptyView()
            }
            
            Spacer()
            Text(tool.title)
                .font(.headline)
        }
        .padding()
        .allFrame()
        .background(Color(.systemGray6))
    }
}



