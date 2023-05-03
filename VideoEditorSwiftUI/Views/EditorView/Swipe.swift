//
//  Swipe.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 02.05.2023.
//

import SwiftUI

struct TestView: View {
   @State var rows = [1, 2, 3, 4, 5, 6]
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0){
                ForEach(rows, id: \.self) { index in
                    VStack{
                        HStack{
                            Text("\(index)")
                            Spacer()
                        }
                        .padding()
                        Divider()
                    }
                    .swipeAction{
                        withAnimation {
                            rows.removeAll(where: {$0 == index})
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

extension View {
    
    func onDelete(perform action: @escaping () -> Void) -> some View {
        self.modifier(Delete(action: action))
    }
    
    func swipeAction(perform action: @escaping () -> Void) -> some View{
        self.modifier(Swipe(action: action))
    }
}

struct Swipe: ViewModifier{
    let halfDeletionDistance: CGFloat = 70
    @State private var isSwiped: Bool = false
    @State private var offset: CGFloat = .zero
    let action: () -> Void
    
    func body(content: Content) -> some View {
        
        ZStack{
            Color.red
            
            HStack{
                Spacer()
                Button {
                    delete()
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
            }
            content
                .background(.white)
                .contentShape(Rectangle())
                .offset(x: offset)
                .gesture(DragGesture().onChanged(onChange).onEnded(onEnded))
                .animation(.easeIn, value: offset)
                
        }
    }

    private func onChange(_ value: DragGesture.Value){
        
      
            if value.translation.width < 0{
                if isSwiped{
                    offset = value.translation.width - halfDeletionDistance
                }
                else{
                    offset = value.translation.width
                }
            }
        
    }
    
    private func onEnded(_ value: DragGesture.Value){
        if value.translation.width < 0{
            if -offset > 50{
                isSwiped = true
                offset = -halfDeletionDistance
            }else{
                isSwiped = false
                offset = .zero
            }
        }else{
            isSwiped = false
            offset = .zero
        }
    }
    
    private func delete(){
        offset = -1000
        action()
    }
}



struct Delete: ViewModifier {

    let action: () -> Void
    
    @State var offset: CGSize = .zero
    @State var initialOffset: CGSize = .zero
    @State var contentWidth: CGFloat = 0.0
    @State var willDeleteIfReleased = false
   
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
//                            .clipShape(CustomCorners(corners: [.topLeft, .bottomLeft], radius: 7))
                            .foregroundColor(.red)
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title2.bold())
                            .layoutPriority(-1)
                    }
                    .frame(width: -offset.width)
                    .clipShape(Rectangle() )
                    .offset(x: geometry.size.width)
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.2)){
                            contentWidth = geometry.size.width
                        }
                    }
                    .gesture(
                        TapGesture()
                            .onEnded {
                                delete()
                            }
                    )
                }
            )
            .offset(x: offset.width, y: 0)
            .gesture (
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width + initialOffset.width <= 0 {
                            self.offset.width = gesture.translation.width + initialOffset.width
                        }
                        if self.offset.width < -deletionDistance && !willDeleteIfReleased {
                            hapticFeedback()
                            willDeleteIfReleased.toggle()
                        } else if offset.width > -deletionDistance && willDeleteIfReleased {
                            hapticFeedback()
                            willDeleteIfReleased.toggle()
                        }
                    }
                    .onEnded { _ in
                        if offset.width < -deletionDistance {
                            delete()
                        } else if offset.width < -halfDeletionDistance {
                            offset.width = -tappableDeletionWidth
                            initialOffset.width = -tappableDeletionWidth
                        } else {
                            offset = .zero
                            initialOffset = .zero
                        }
                    }
            )
            .animation(.interactiveSpring(), value: offset)
            .animation(.interactiveSpring(), value: initialOffset)
            .animation(.interactiveSpring(), value: willDeleteIfReleased)
    }
    
    private func delete() {
        
        //offset.width = -contentWidth
        offset = .zero
        initialOffset = .zero
        action()
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    //MARK: Constants
    
    let deletionDistance = CGFloat(100)
    let halfDeletionDistance = CGFloat(50)
    let tappableDeletionWidth = CGFloat(100)
    
    
}
