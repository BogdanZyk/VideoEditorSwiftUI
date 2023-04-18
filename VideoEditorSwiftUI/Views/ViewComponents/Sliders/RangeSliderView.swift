//
//  RangeSliderView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 17.04.2023.
//

import SwiftUI

struct RangedSliderView<T: View>: View {
    let currentValue: Binding<ClosedRange<Double>>?
    let sliderBounds: ClosedRange<Double>
    let step: Double
    let onEndChange: () -> Void
    var thumbView: T
    
    init(value: Binding<ClosedRange<Double>>?, bounds: ClosedRange<Double>, step: Double = 1, onEndChange: @escaping () -> Void, @ViewBuilder thumbView: () -> T) {
        self.onEndChange = onEndChange
        self.step = step
        self.currentValue = value
        self.sliderBounds = bounds
        self.thumbView = thumbView()
    }
    
    var body: some View {
        GeometryReader { geomentry in
            sliderView(sliderSize: geomentry.size)
        }
    }
    
        
    @ViewBuilder private func sliderView(sliderSize: CGSize) -> some View {
        let sliderViewYCenter = sliderSize.height / 2
        ZStack {
            Rectangle()
                .fill(Color(.systemGray5).opacity(0.75))
                .frame(height: sliderSize.height)
            ZStack {
                let sliderBoundDifference = sliderBounds.upperBound / step
                let stepWidthInPixel = CGFloat(sliderSize.width) / CGFloat(sliderBoundDifference)
                
                // Calculate Left Thumb initial position
                let leftThumbLocation: CGFloat = currentValue?.wrappedValue.lowerBound == sliderBounds.lowerBound
                    ? 0
                : CGFloat((currentValue?.wrappedValue.lowerBound ?? 0) - sliderBounds.lowerBound) * stepWidthInPixel
                
                // Calculate right thumb initial position
                let rightThumbLocation = CGFloat(currentValue?.wrappedValue.upperBound ?? 1) * stepWidthInPixel
                let height = rightThumbLocation - leftThumbLocation
                // Path between both handles
                
            
                thumbView
                    .frame(width: height, height: sliderSize.height)
                    .position(x: sliderSize.width - (sliderSize.width - leftThumbLocation - height / 2) , y: sliderViewYCenter)
                    
                
                // Left Thumb Handle
                let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
                thumbView(height: sliderSize.height, position: leftThumbPoint, isLeftThumb: true)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        
                        let dragLocation = dragValue.location
                        let xThumbOffset = min(max(0, dragLocation.x), sliderSize.width)
                        
                        let newValue = (sliderBounds.lowerBound) + (xThumbOffset / stepWidthInPixel)
                        
                        // Stop the range thumbs from colliding each other
                        if newValue < currentValue?.wrappedValue.upperBound ?? 1 {
                            currentValue?.wrappedValue = newValue...(currentValue?.wrappedValue.upperBound ?? 1)
                        }
                    }.onEnded({ _ in
                        onEndChange()
                    }))
                
                // Right Thumb Handle
                thumbView(height: sliderSize.height, position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), isLeftThumb: false)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        let dragLocation = dragValue.location
                        let xThumbOffset = min(max(CGFloat(leftThumbLocation), dragLocation.x), sliderSize.width)
                        
                        var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
                        newValue = min(newValue, sliderBounds.upperBound)
                        
                        // Stop the range thumbs from colliding each other
                        if newValue > currentValue?.wrappedValue.lowerBound ?? 0 {
                            currentValue?.wrappedValue = (currentValue?.wrappedValue.lowerBound ?? 0)...newValue
                        }
                    }.onEnded({ _ in
                        onEndChange()
                    }))
            }
        }
        .compositingGroup()
    }
    
    @ViewBuilder func lineBetweenThumbs(height: CGFloat, from: CGPoint, to: CGPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }.stroke(Color.white, lineWidth: height + 5)
    }
    
    @ViewBuilder func thumbView(height: CGFloat, position: CGPoint, isLeftThumb: Bool) -> some View {
        let width = 14
        Rectangle()
            .frame(width: 14, height: height)
            .foregroundColor(.red)
            .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 2)
            .contentShape(Rectangle())
            .overlay(alignment: .center) {
                Image(systemName: isLeftThumb ? "chevron.left" : "chevron.right")
                    .imageScale(.small)
                    
            }
            .position(x: position.x + CGFloat((isLeftThumb ? -(width/2) : width/2)), y: position.y)
            
    }
}

struct RangeSliderView_Previews: PreviewProvider {
    static var previews: some View {
        RangedSliderView(value: .constant(16...60), bounds: 1...100, onEndChange: {}, thumbView: {Rectangle().blendMode(.destinationOut)})
            .frame(height: 60)
            .padding()
    }
}
