//
//  ThumbnailsSliderView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 17.04.2023.
//

import SwiftUI
import AVKit

struct ThumbnailsSliderView: View {
    @State private var isHiddenTimeSlider: Bool = false
    @Binding var curretTime: Double
    @StateObject var viewModel = ThumbnailsSliderViewModel()
    var loadedState: LoadState
    let onChangeTimeValue: () -> Void
    var body: some View {
        GeometryReader { proxy in
            ZStack{
                thumbnailsImagesSection(proxy)
                    .border(Color.secondary, width: 2)
                if let _ = viewModel.asset{
                    RangedSliderView(value: $viewModel.trimRange, bounds: viewModel.duration, onEndChange: { setOnChangeTrim(false)}) {
//                        if !isHiddenTimeSlider{
//                            LineSlider(value: $curretTime, range: viewModel.trimRange, onEditingChanged: onChangeTimeValue)
//                        }
                    }
                    .onChange(of: viewModel.trimRange.upperBound) { upperBound in
                        curretTime = Double(upperBound)
                        onChangeTimeValue()
                        setOnChangeTrim(true)
                    }
                    .onChange(of: viewModel.trimRange.lowerBound) { lowerBound in
                        curretTime = Double(lowerBound)
                        onChangeTimeValue()
                        setOnChangeTrim(true)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            
            .onChange(of: loadedState) { type in
                switch type{
                case .loaded(let url):
                    viewModel.updateThumbnails(url: url, geo: proxy)
                    print(viewModel.thumbnailsImages.count)
                default:
                    break
                }
            }
        }
        .frame(width: getRect().width - 32, height: 70)
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}

struct ThumbnailsSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailsSliderView(curretTime: .constant(0), loadedState: .failed, onChangeTimeValue: {})
    }
}


extension ThumbnailsSliderView{
    
    
    private func thumbnailsImagesSection(_ proxy: GeometryProxy) -> some View{
        HStack(spacing: 0){
            ForEach(viewModel.thumbnailsImages) { trimData in
                if let image = trimData.image{
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width / CGFloat(viewModel.thumbnailsImages.count), height: proxy.size.height - 5)
                        .clipped()
                }
            }
        }
    }
    
    private func setOnChangeTrim(_ isChange: Bool){
        isHiddenTimeSlider = isChange
        if !isChange{
            curretTime = viewModel.trimRange.lowerBound
            onChangeTimeValue()
        }
    }
}




