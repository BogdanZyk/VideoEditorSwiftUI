//
//  SheetView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 24.04.2023.
//

import SwiftUI

struct SheetView<Content: View>: View {
    @Binding var isPresented: Bool
    @State private var showSheet: Bool = false
    @State private var slideGesture: CGSize
    var bgOpacity: CGFloat
    let content: Content
    init(isPresented: Binding<Bool>, bgOpacity: CGFloat = 0.01,  @ViewBuilder content: () -> Content){
        self._isPresented = isPresented
        self.bgOpacity = bgOpacity
        self._slideGesture = State(initialValue: CGSize.zero)
        self.content = content()
        
    }
    var body: some View {
        ZStack(alignment: .bottom){
            Color.black.opacity(bgOpacity)
                .onTapGesture {
                    closeSheet()
                }
                .onAppear{
                    withAnimation(.spring().delay(0.1)){
                        showSheet = true
                    }
                }
            if showSheet{
                sheetLayer
                    .transition(.move(edge: .bottom))
                    .onDisappear{
                        withAnimation(.easeIn(duration: 0.1)){
                            isPresented = false
                        }
                    }
            }
        }
    }
}


extension SheetView{
    private var sheetLayer: some View{
        VStack(spacing: 0){
            HStack(alignment: .top, spacing: -20){
                Spacer()
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 80, height: 6)
                Spacer()
                Button {
                    closeSheet()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            content
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -5)
        .gesture(DragGesture().onChanged{ value in
            self.slideGesture = value.translation
        }
            .onEnded{ value in
                if self.slideGesture.height > -10 {
                    closeSheet()
                }
                self.slideGesture = .zero
            })
    }
    
    private func closeSheet(){
        withAnimation(.easeIn(duration: 0.2)){
            showSheet = false
        }
    }
}


struct CustomCorners: Shape {
    
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


