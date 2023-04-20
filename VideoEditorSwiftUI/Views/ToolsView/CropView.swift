//
//  CropView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import SwiftUI

struct CropView<T: View>: View{
    let originalSize: CGSize
    var rotation: Double?
    var isActive: Bool
    @ViewBuilder
    var frameView: () -> T
    var body: some View {
        ZStack{
            frameView()
                .frame(width: originalSize.width, height: originalSize.height)
                .border(isActive ? Color.white : .clear)
        }
        .scaleEffect(isActive ? 0.9 : 1)
        .rotationEffect(.degrees(rotation ?? 0))
        .clipped()
    }
}

struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            CropView(originalSize: .init(width: 300, height: 600), rotation: nil, isActive: true){
                Rectangle()
            }
            .frame(height: proxy.size.height / 1.45)
        }
    }
}



struct CropFrame: Shape {
    let isActive: Bool
    func path(in rect: CGRect) -> Path {
        guard isActive else { return Path(rect) } 

        let size = CGSize(width: getRect().width * 0.7, height: getRect().height/5)
        let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
        return Path(CGRect(origin: origin, size: size).integral)
    }
}

struct CropImage<T: View>: View{

    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var clipped = false
    
    @ViewBuilder
    var frameView: () -> T
    
    

    var body: some View {
        VStack {
            ZStack {
                frameView()
                    .offset(x: self.currentPosition.width, y: self.currentPosition.height)

                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: getRect().width * 0.7 , height: getRect().height/5)
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 3))
            }
            .clipShape(
                CropFrame(isActive: clipped)
            )
            .gesture(DragGesture()
                .onChanged { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
            }
            .onEnded { value in
                self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)

                self.newPosition = self.currentPosition
            })


            Button (action : { self.clipped.toggle() }) {
                Text("Crop Image")
                    .padding(.all, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .shadow(color: .gray, radius: 1)
                    .padding(.top, 50)
            }
        }
    }
}
