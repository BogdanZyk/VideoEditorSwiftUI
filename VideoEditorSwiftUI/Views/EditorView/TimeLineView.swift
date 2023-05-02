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
    var activateTextSlider: Bool
    var video: Video
    var textInterval: ClosedRange<Double>?
    let onChangeTimeValue: () -> Void
    let onChangeTextTime: (ClosedRange<Double>) -> Void
    
    private let frameWight: CGFloat = 55
    
    private var calcWight: CGFloat{
        frameWight + (activateTextSlider ? 40 : 10)
    }
    var body: some View {
        ZStack{
            if let image = video.thumbnailsImages.first?.image{
                TimelineSlider(bounds: video.rangeDuration, disableOffset: isActiveTextRangeSlider, value: $currentTime, frameWight: calcWight) {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: calcWight, height: frameWight)
                            .clipped()
                        
                        if let textInterval, activateTextSlider{
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
                } onChange: {
                    onChangeTimeValue()
                }
            }
        }
        .frame(height: 60)
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
        .onChange(of: activateTextSlider) { newValue in
            if !newValue{
                currentTime = 0
                onChangeTimeValue()
            }
        }
    }
}

struct TimeLineView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineView(currentTime: .constant(0), activateTextSlider: false, video:  Video.mock, onChangeTimeValue: {}, onChangeTextTime: {_ in})
    }
}

