//
//  TimeLineView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct TimeLineView: View {
    var video: Video
    @Binding var curretTime: Double
    let frameWigth: CGFloat = 64
    let onChangeTimeValue: () -> Void
    var body: some View {
        Group{
            if let image = video.thumbnailsImages.first?.image{
                TimelineSlider(bounds: video.rangeDuration, value: $curretTime, frameWigth: frameWigth) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: frameWigth + 10, height: frameWigth)
                        .clipped()
                } onChange: {
                    onChangeTimeValue()
                }
                .frame(height: 74)
            }
        }
    }
}

struct TimeLineView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineView(video: Video.mock, curretTime: .constant(0), onChangeTimeValue: {})
    }
}

