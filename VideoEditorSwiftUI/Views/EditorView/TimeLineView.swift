//
//  TimeLineView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct TimeLineView: View {
    var video: Video
    @Binding var currentTime: Double
    let frameWight: CGFloat = 55
    let onChangeTimeValue: () -> Void
    var body: some View {
        Group{
            if let image = video.thumbnailsImages.first?.image{
                TimelineSlider(bounds: video.rangeDuration, value: $currentTime, frameWigth: frameWight) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: frameWight + 10, height: frameWight)
                        .clipped()
                } onChange: {
                    onChangeTimeValue()
                }
                .frame(height: 60)
            }
        }
    }
}

struct TimeLineView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineView(video: Video.mock, currentTime: .constant(0), onChangeTimeValue: {})
    }
}

