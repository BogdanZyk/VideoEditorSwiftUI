//
//  CustomSlider.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 17.04.2023.
//

import SwiftUI

struct CustomSlider<Value, Track, Thumb>: View
where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint, Track: View, Thumb: View {
    // the value of the slider, inside `bounds`
    @Binding var value: Value
    // range to which the thumb offset is mapped
    let bounds: ClosedRange<Value>
    // tells how discretely does the value change
    let step: Value
    // left-hand label
    let minimumValueLabel: Text?
    // right-hand label
    let maximumValueLabel: Text?
    // called with `true` when sliding starts and with `false` when it stops
    let onEditingChanged: ((Bool) -> Void)?
    let onChanged: (() -> Void)?
    // the track view
    let track: () -> Track
    // the thumb view
    let thumb: () -> Thumb
    // tells how big the thumb is. This is here because there's no good
    // way in SwiftUI to get the thumb size at runtime, and its an important
    // to know it in order to compute its insets in the track overlay.
    let thumbSize: CGSize
    
    // x offset of the thumb from the track left-hand side
    @State private var xOffset: CGFloat = 0
    // last moved offset, used to decide if sliding has started
    @State private var lastOffset: CGFloat = 0
    // the size of the track view. This can be obtained at runtime.
    @State private var trackSize: CGSize = .zero
    @State private var isOnChange: Bool = false
    
    // initializer allows us to set default values for some view params
    init(value: Binding<Value>,
         in bounds: ClosedRange<Value> = 0...1,
         step: Value = 0.001,
         minimumValueLabel: Text? = nil,
         maximumValueLabel: Text? = nil,
         onEditingChanged: ((Bool) -> Void)? = nil,
         onChanged: (() -> Void)? = nil,
         track: @escaping () -> Track,
         thumb: @escaping () -> Thumb,
         thumbSize: CGSize) {
        _value = value
        self.bounds = bounds
        self.step = step
        self.minimumValueLabel = minimumValueLabel
        self.maximumValueLabel = maximumValueLabel
        self.onEditingChanged = onEditingChanged
        self.onChanged = onChanged
        self.track = track
        self.thumb = thumb
        self.thumbSize = thumbSize
    }
    
    // where does the current value sit, percentage-wise, in the provided bounds
    private var percentage: Value {
        1 - (bounds.upperBound - value) / (bounds.upperBound - bounds.lowerBound)
    }
    
    // how wide the should the fill view be
    private var fillWidth: CGFloat {
        trackSize.width * CGFloat(percentage)
    }
    
    var body: some View {
        // the HStack orders minimumValueLabel, the slider and maximumValueLabel horizontally
        HStack {
            minimumValueLabel
            
            // Represent the custom slider. ZStack overlays `fill` on top of `track`,
            // while the `thumb` is in their `overlay`.
            ZStack {
                track()
                // get the size of the track at runtime as it
                // defines all the other functionality
                    .measureSize {
                        // if this is the first time trackSize is computed,
                        // update the offset to reflect the current `value`
                        let firstInit = (trackSize == .zero)
                        trackSize = $0
                        if firstInit {
                            xOffset = (trackSize.width - thumbSize.width) * CGFloat(percentage)
                            lastOffset = xOffset
                        }
                    }
                    .onChange(of: value) { _ in
                        if !isOnChange{
                            xOffset = (trackSize.width - thumbSize.width) * CGFloat(percentage)
                            lastOffset = xOffset
                        }
                    }
            }
            // make sure the entire ZStack is the same size as `track`
            .frame(width: trackSize.width, height: trackSize.height)
            // the thumb lives in the ZStack overlay
            .overlay(thumb()
                     // adjust the insets so that `thumb` doesn't sit outside the `track`
                .position(x: thumbSize.width / 2,
                          y: thumbSize.height / 2)
                     // set the size here to make sure it's really the same as the
                     // provided `thumbSize` parameter
                .frame(width: thumbSize.width, height: thumbSize.height)
                     // set the offset to, well, the stored xOffset
                .offset(x: xOffset)
                     // use the DragGesture to move the `thumb` around as adjust xOffset
                .gesture(DragGesture(minimumDistance: 0).onChanged({ gestureValue in
                    // make sure at least some dragging was done to trigger `onEditingChanged`
                    if abs(gestureValue.translation.width) < 0.1 {
                       lastOffset = xOffset
                        onEditingChanged?(true)
                        isOnChange = true
                    }
                    // update xOffset by the gesture translation, making sure it's within the view's bounds
                    let availableWidth = trackSize.width - thumbSize.width
                    xOffset = max(0, min(lastOffset + gestureValue.translation.width, availableWidth))
                    // update the value by mapping xOffset to the track width and then to the provided bounds
                    // also make sure that the value changes discretely based on the `step` para
                    let newValue = (bounds.upperBound - bounds.lowerBound) * Value(xOffset / availableWidth) + bounds.lowerBound
                    let steppedNewValue = (round(newValue / step) * step)
                    value = min(bounds.upperBound, max(bounds.lowerBound, steppedNewValue))
                    onChanged?()
                }).onEnded({ _ in
                    // once the gesture ends, trigger `onEditingChanged` again
                    onEditingChanged?(false)
                    isOnChange = false
                })),
                     alignment: .leading)
            
            maximumValueLabel
        }
        // manually set the height of the entire view to account for thumb height
        .frame(height: max(trackSize.height, thumbSize.height))
    }
}

struct CustomSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomSlider(value: .constant(10),
                     in: 10...255,
                     step: 90,
                     minimumValueLabel: Text("Min"),
                     maximumValueLabel: Text("Max"),
                     onEditingChanged: { started in
            print("started custom slider: \(started)")
        }, track: {
            Capsule()
                .foregroundColor(.init(red: 0.9, green: 0.9, blue: 0.9))
                .frame(width: 200, height: 5)
        }, thumb: {
            Circle()
                .foregroundColor(.white)
                .shadow(radius: 20 / 1)
        }, thumbSize: CGSize(width: 20, height: 20))
    }
}




struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct MeasureSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self,
                                   value: geometry.size)
        })
    }
}

extension View {
    func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
        self.modifier(MeasureSizeModifier())
            .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
}
