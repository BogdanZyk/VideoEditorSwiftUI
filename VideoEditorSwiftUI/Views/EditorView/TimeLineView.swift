//
//  TimeLineView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct TimeLineView: View {
    @ObservedObject var recorderManager: AudioRecorderManager
    @State private var isActiveTextRangeSlider: Bool = false
    @State private var textTimeInterval: ClosedRange<Double> = 0...1
    @Binding var currentTime: Double
    @Binding var isSelectedTrack: Bool
    var viewState: TimeLineViewState = .empty
    var video: Video
    var textInterval: ClosedRange<Double>?
    let onChangeTimeValue: () -> Void
    let onChangeTextTime: (ClosedRange<Double>) -> Void
    let onSetAudio: (Audio) -> Void
    private let frameWight: CGFloat = 55

    private var calcWight: CGFloat{
        frameWight * CGFloat(viewState.countImages) + 10
    }
    var body: some View {
        ZStack{
            if !video.thumbnailsImages.isEmpty{
                TimelineSlider(bounds: video.rangeDuration, disableOffset: isActiveTextRangeSlider, value: $currentTime, frameWight: calcWight) {
                    VStack(alignment: .leading, spacing: 5) {
                        ZStack {
                            tubneilsImages(video.thumbnailsImages)
                            textRangeTimeLayer
                        }
                        audioLayerSection
                    }
                } actionView: {
                    recordButton
                }
            onChange: {
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
            TimeLineView(recorderManager: AudioRecorderManager(), currentTime: .constant(0), isSelectedTrack: .constant(true), viewState: .audio, video: video, onChangeTimeValue: {}, onChangeTextTime: {_ in}, onSetAudio: {_ in})
        }
    }
}



extension TimeLineView{
    
    private func tubneilsImages(_ images: [ThumbnailImage]) -> some View{
        let images = firstAndAverageImage(images)
        return HStack(spacing: 0){
            ForEach(images) { image in
                if let image = image.image{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: frameWight)
                        .clipped()
                }
            }
        }
        .overlay {
            if viewState == .audio{
                if isSelectedTrack{
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(lineWidth: 2)
                        .foregroundColor(.white)
                }
                HStack(spacing: 1){
                    if video.volume > 0{
                        Image(systemName: "speaker.wave.2.fill")
                        Text(verbatim: String(Int(video.volume * 100)))
                    }else{
                        Image(systemName: "speaker.slash.fill")
                    }
                }
                .font(.system(size: 9))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(5)
            }
        }
        .onTapGesture {
            if viewState == .audio, !isSelectedTrack{
                isSelectedTrack.toggle()
                currentTime = 0
                onChangeTimeValue()
            }
        }
    }
    
    private func firstAndAverageImage(_ images: [ThumbnailImage]) -> [ThumbnailImage]{
        guard let first = images.first else {return []}
        
        var newArray = [first]
        
        if viewState == .audio || viewState == .text{
            let averageIndex = Int(images.count / 2)
            newArray.append(images[averageIndex])
        }
        return newArray
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
    
    private var recordButton: some View{
        Group{
            if viewState == .audio{
                RecorderButtonView(video: video, recorderManager: recorderManager, onRecorded: onSetAudio) { time in
                    currentTime = time
                    onChangeTimeValue()
                }
                .vBottom()
                .padding(.bottom, viewState.height / 6)
            }else{
                Rectangle()
                    .opacity(0)
            }
        }
    }
    
    private var audioLayerSection: some View{
        Group{
            if viewState == .audio{
                AudioButtonView(
                    video: video,
                    isSelectedTrack: $isSelectedTrack,
                    recorderManager: recorderManager)
            }
        }
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
    var countImages: Int{
        switch self {
        case .audio, .text: return 2
        case .empty: return 1
        }
    }
}

