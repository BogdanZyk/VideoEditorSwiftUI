//
//  TestCroppedView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 21.04.2023.
//

import SwiftUI

struct TestCroppedView: View {
    @State private var position = CGPoint(x: 100, y: 100)
    private var rectSize: CGFloat = 350
    let size: CGSize = .init(width: 200, height: 400)
    let frameSize: CGSize = .init(width: 350, height: 700)
    var body: some View {
        VStack {
            Text("Current postion = (x: \(Int(position.x)), y: \(Int(position.y))")
            
            Rectangle()
                .fill(.gray)
                .frame(width: frameSize.width, height: frameSize.height)
                .overlay(
                    Rectangle()
                        .fill(.clear)
                        .border(.blue, width: 2.0)
                        .contentShape(Rectangle())
                        .frame(width: size.width, height: size.height)
                        .position(position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // limit movement to min and max value
                                    let limitedX = max(min(value.location.x, frameSize.width - size.width / 2), size.width / 2)
                                    let limitedY = max(min(value.location.y, frameSize.height - size.height / 2), size.height / 2)
                                    
                                    self.position = CGPoint(x: limitedX,
                                                            y: limitedY)
                                }
                        )
                )
        }
    }
}

struct TestCroppedView_Previews: PreviewProvider {
    static var previews: some View {
        TestCroppedView()
    }
}
