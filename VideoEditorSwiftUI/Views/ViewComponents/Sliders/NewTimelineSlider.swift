//
//  NewTimelineSlider.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 19.04.2023.
//

import SwiftUI

struct TimelineSlider<T: View>: View {
    @State private var lastOffset: CGFloat = 0
    var bounds: ClosedRange<Double>
    @Binding var value: Double
    @State var isChange: Bool = false
    @State var offset: CGFloat = 0
    @State var gestureW: CGFloat = 0
    var frameWigth: CGFloat = 65
    @ViewBuilder
    var frameView: () -> T
    let onChange: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            let sliderViewYCenter = proxy.size.height / 2
            let sliderPositionX = proxy.size.width / 2 + frameWigth / 2 + offset
            ZStack{
               
                frameView()
                    .frame(width: frameWigth, height: proxy.size.height - 5)
                    .position(x: sliderPositionX, y: sliderViewYCenter)
                    .overlay(content: {
                        VStack {
                            Text("\(offset)")
                            Text("\(gestureW)")
                        }
                    })
                Capsule()
                    .fill(Color.white)
                    .frame(width: 4, height: proxy.size.height)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 0)

            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        isChange = true
                        
                        gestureW = gesture.translation.width * 0.5
                        
                        if abs(gesture.translation.width) > 0.1 {
                           lastOffset = offset
                        }
                       
                        offset = min(0, max((-lastOffset + gesture.translation.width) * 0.5, -frameWigth))
                        
                        
                        
                        let newValue = (bounds.upperBound - bounds.lowerBound) * (offset / frameWigth) - bounds.lowerBound
                        
                        value = abs(newValue)
                        
                        onChange()
                        
                    }
                    .onEnded { _ in
                        isChange = false
                    }
            )
            //.animation(.easeIn, value: offset)
            .onChange(of: value) { _ in
               setOffset()
            }
        }
    }
}

struct NewTimelineSlider_Previews: PreviewProvider {
    @State static var curretTime = 0.0
    static var previews: some View {
        TimelineSlider(bounds: 5...34, value: $curretTime, frameView: {
            Rectangle()
                .fill(Color.secondary)
        }, onChange: {})
            .frame(height: 80)
    }
}

extension TimelineSlider{
    
    private func setOffset(){
        if !isChange{
            offset = ((-value + bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * frameWigth
        }
    }
}
