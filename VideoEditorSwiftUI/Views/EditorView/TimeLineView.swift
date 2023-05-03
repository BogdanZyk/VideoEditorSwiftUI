//
//  TimeLineView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct TimeLineView: View {
    @State private var isActiveTextRangeSlider: Bool = false
    @State private var textTimeInterval: ClosedRange<Double> = 0...1
    @Binding var currentTime: Double
    var viewState: TimeLineViewState = .empty
    var video: Video
    var textInterval: ClosedRange<Double>?
    let onChangeTimeValue: () -> Void
    let onChangeTextTime: (ClosedRange<Double>) -> Void
    
    private let frameWight: CGFloat = 55
    
    private var calcWight: CGFloat{
        frameWight + viewState.wight
    }
    var body: some View {
        ZStack{
            if let image = video.thumbnailsImages.first?.image{
                TimelineSlider(bounds: video.rangeDuration, disableOffset: isActiveTextRangeSlider, value: $currentTime, frameWight: calcWight) {
                    VStack(alignment: .leading, spacing: 5) {
                        ZStack {
                            tubneilsImage(image)
                            textRangeTimeLayer
                        }
                        audioLayerSection
                    }
                } onChange: {
                    onChangeTimeValue()
                }
            }
        }
        .frame(height: viewState.height)
        .onChange(of: textTimeInterval.lowerBound) { newValue in
            isActiveTextRangeSlider = true
            currentTime = newValue
            onChangeTimeValue()
            onChangeTextTime(textTimeInterval)
        }
        .onChange(of: textTimeInterval.upperBound) { newValue in
            isActiveTextRangeSlider = true
            currentTime = newValue
            onChangeTimeValue()
            onChangeTextTime(textTimeInterval)
        }
        .onChange(of: textInterval) { newValue in
            if let newValue{
                textTimeInterval = newValue
            }
        }
        .onChange(of: viewState) { newValue in
            if newValue == .empty{
                currentTime = 0
                onChangeTimeValue()
            }
        }
    }
}

struct TimeLineView_Previews: PreviewProvider {
    static var video: Video {
        var video = Video.mock
        video.thumbnailsImages = [.init(image: UIImage(systemName: "person")!)]
        return video
    }
    static var previews: some View {
        ZStack{
            Color.secondary
            TimeLineView(currentTime: .constant(0), viewState: .audio, video: video, onChangeTimeValue: {}, onChangeTextTime: {_ in})
        }
    }
}



extension TimeLineView{
    
    private func tubneilsImage(_ image: UIImage) -> some View{
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: calcWight, height: frameWight)
            .clipped()
    }
    
    private var textRangeTimeLayer: some View{
        Group{
            if let textInterval, viewState == .text{
                RangedSliderView(value: $textTimeInterval, bounds: 0...video.originalDuration, onEndChange: {
                    isActiveTextRangeSlider = false
                }) {
                    Rectangle().blendMode(.destinationOut)
                }
                .frame(width: calcWight)
                .onAppear{
                    textTimeInterval = textInterval
                }
                .onDisappear{
                    isActiveTextRangeSlider = false
                }
            }
        }
    }
    
    private var audioLayerSection: some View{
        Group{
            if viewState == .audio{
                
                ZStack(alignment: .leading){
                    Color(.systemGray5)
                    if let url = video.audioURL{
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary)
                    }else{
                        Button {
                            
                        } label: {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .frame(height: 40)
    }
}

enum TimeLineViewState: Int{
    case text, audio, empty
    
    var wight: CGFloat{
        switch self {
        case .text, .audio: return 40
        case .empty: return 10
        }
    }
    
    var height: CGFloat{
        switch self {
        case .audio: return 110
        case .empty, .text: return 60
        }
    }
}

