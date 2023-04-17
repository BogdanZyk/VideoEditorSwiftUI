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
        VStack {
            Text(Int(curretTime).secondsToTime())
            if let asset = viewModel.asset{
                Text(Int(asset.videoDuration()).secondsToTime())
            }
            
            GeometryReader { proxy in
                
                ZStack{
                    thumbnailsImagesSection(proxy)
                        .border(Color.secondary, width: 2)
                    if let _ = viewModel.asset{
                        RangedSliderView(value: $viewModel.trimRange, bounds: viewModel.duration, onEndChange: { setOnChangeTrim(false)}) {
                            if !isHiddenTimeSlider{
                                TimeLineSlider(value: $curretTime, range: viewModel.trimRange, onEditingChanged: onChangeTimeValue)
//                                SliderView(value: $curretTime, in: viewModel.trimRange, height: proxy.size.height, onChange: onChangeTimeValue)
                            }
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
            print(viewModel.trimRange)
            onChangeTimeValue()
        }
    }
}




class ThumbnailsSliderViewModel: ObservableObject{
    
    @Published var thumbnailsImages = [ThumbnailImage]()
    @Published var trimRange: ClosedRange<Double> = 0...0.1
    var asset: AVAsset?
    
    
    var duration: ClosedRange<Double>{
        0...(asset?.videoDuration() ?? 0.1)
    }
    
    func updateThumbnails(url: URL, geo: GeometryProxy){
        
        let asset = AVAsset(url: url)
        self.asset = asset
        let duration = asset.videoDuration()
        
        thumbnailsImages.removeAll()
        
        let imagesCount = thumbnailCount(geo: geo)
        
        var offset: Float64 = 0
        for i in 0..<imagesCount{
            let thumbnailImage = ThumbnailImage(time: offset, image: asset.getImage(Int(offset)))
            offset = Double(i) * (duration / Double(imagesCount))
            thumbnailsImages.append(thumbnailImage)
        }
        
        trimRange = 0...asset.videoDuration()
    }
    

    private func thumbnailCount(geo: GeometryProxy) -> Int {
        
        let num = Double(geo.size.width) / Double(geo.size.height / 1.5)
        
        return Int(ceil(num))
    }
}
