//
//  TimeLineView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct TimeLineView: View {
    @ObservedObject var editorVM: EditorViewModel
    @Binding var curretTime: Double
    let onChangeTimeValue: () -> Void
    
    var duration: ClosedRange<Double>{
        0...(editorVM.asset?.videoDuration() ?? 0.1)
    }
    
    var body: some View {
        ZStack{
            if let image = editorVM.asset?.getImage(1){
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
            }else{
                Rectangle()
                    .fill(Color.secondary)
                    .frame(height: 60)
            }
            LineSlider(value: $curretTime, range: duration, onEditingChanged: onChangeTimeValue)
                .frame(height: 70)
        }
        .frame(width: 80, height: 70)
    }
}

struct TimeLineView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineView(editorVM: EditorViewModel(), curretTime: .constant(0), onChangeTimeValue: {})
    }
}

extension TimeLineView{
    
    

    
    
}
