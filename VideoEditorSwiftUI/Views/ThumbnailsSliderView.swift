//
//  ThumbnailsSliderView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 17.04.2023.
//

import SwiftUI
import AVKit

struct ThumbnailsSliderView: View {
    @State var rangeDuration: ClosedRange<Double> = 0...1
    @Binding var curretTime: Double
    @Binding var video: Video?
    let onChangeTimeValue: () -> Void
    
    
    private var totalDuration: Double{
        rangeDuration.upperBound - rangeDuration.lowerBound
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(totalDuration.formatterTimeString())
                .foregroundColor(.white)
                .font(.subheadline)
            GeometryReader { proxy in
                ZStack{
                    thumbnailsImagesSection(proxy)
                        .border(Color.secondary, width: 2)
                    if let video{
                        RangedSliderView(value: $rangeDuration, bounds: 0...video.originalDuration, onEndChange: { setOnChangeTrim(false)}) {
                            Rectangle().blendMode(.destinationOut)
                        }
                        .onChange(of: self.video?.rangeDuration.upperBound) { upperBound in
                            if let upperBound{
                                curretTime = Double(upperBound)
                                onChangeTimeValue()
                                setOnChangeTrim(true)
                            }
                        }
                        .onChange(of: self.video?.rangeDuration.lowerBound) { lowerBound in
                            if let lowerBound{
                                curretTime = Double(lowerBound)
                                onChangeTimeValue()
                                setOnChangeTrim(true)
                            }
                        }
                        .onChange(of: rangeDuration) { newValue in
                            self.video?.rangeDuration = newValue
                        }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .onAppear{
                    if let video{
                        rangeDuration = video.rangeDuration
                    }
                }
            }
            .frame(width: getRect().width - 64, height: 70)
        .padding(.vertical, 10)
        }
    }
}

struct ThumbnailsSliderView_Previews: PreviewProvider {
   static let url = URL(string: "https://www.google.com/")!
    static var previews: some View {
        ThumbnailsSliderView(curretTime: .constant(0), video: .constant(.init(url:url, asset: AVAsset(url: url), originalDuration: 250, rangeDuration: 0...250)), onChangeTimeValue: {})
    }
}


extension ThumbnailsSliderView{
    
    @ViewBuilder
    private func thumbnailsImagesSection(_ proxy: GeometryProxy) -> some View{
        if let video{
            HStack(spacing: 0){
                ForEach(video.thumbnailsImages) { trimData in
                    if let image = trimData.image{
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width / CGFloat(video.thumbnailsImages.count), height: proxy.size.height - 5)
                            .clipped()
                    }
                }
            }
        }
    }
    
    private func setOnChangeTrim(_ isChange: Bool){
        if !isChange{
            curretTime = video?.rangeDuration.upperBound ?? 0
            onChangeTimeValue()
        }
    }
}




