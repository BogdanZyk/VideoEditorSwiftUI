//
//  VideoSpeedSlider.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 19.04.2023.
//

import SwiftUI

struct VideoSpeedSlider: View {
    @State var value: Double = 1
    var isChangeState: Bool?
    let onEditingChanged: (Float) -> Void
    private let rateRange = 0.1...8
    var body: some View {
        VStack {
            Text(String(format: "%.1fx", value))
            CustomSlider(value: $value,
                         in: rateRange,
                         step: 0.2,
                         onEditingChanged: { started in
                if !started{
                    onEditingChanged(Float(value))
                }
            }, track: {
                Capsule()
                    .foregroundColor(.secondary)
                    .frame(width: 250, height: 5)
            }, thumb: {
                Circle()
                    .foregroundColor(.white)
                    .shadow(radius: 20 / 1)
            }, thumbSize: CGSize(width: 20, height: 20))
        }
        .onChange(of: isChangeState) { isChange in
            if !(isChange ?? true){
                value = 1
            }
        }
    }
}

struct VideoSpeedSlider_Previews: PreviewProvider {
    static var previews: some View {
        VideoSpeedSlider(isChangeState: false){_ in}
    }
}
