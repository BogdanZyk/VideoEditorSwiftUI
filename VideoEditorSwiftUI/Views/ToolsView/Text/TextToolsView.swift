//
//  TextToolsView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 02.05.2023.
//

import SwiftUI

struct TextToolsView: View {
    var video: Video
    @ObservedObject var editor: TextEditorViewModel
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15){
                ForEach(editor.textBoxes) { box in
                    cellView(box)
                }
                addTextButton
            }
        }
        .animation(.easeIn(duration: 0.2), value: editor.textBoxes)
        .onAppear{
            editor.selectedTextBox = editor.textBoxes.first
        }
        .onDisappear{
            editor.selectedTextBox = nil
        }
    }
}

struct TextToolsView_Previews: PreviewProvider {
    static var previews: some View {
        TextToolsView(video: Video.mock, editor: TextEditorViewModel())
    }
}

extension TextToolsView{
    
    private func cellView(_ textBox: TextBox) -> some View{
        let isSelected = editor.isSelected(textBox.id)
        return ZStack{
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(isSelected ?  .systemGray : .systemGray4))
            Text(textBox.text)
                .lineLimit(1)
                .font(.caption)
        }
        .frame(width: 80, height: 80)
        .overlay(alignment: .topLeading) {
            if isSelected{
                Button {
                    editor.removeTextBox()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundColor(Color(.systemGray2))
                        .padding(5)
                        .background(Color.black, in: Circle())
                }
                .padding(5)
            }
        }
        .onTapGesture {
            if isSelected{
                editor.openTextEditor(isEdit: true, textBox)
            }else{
                editor.selectTextBox(textBox)
            }
        }
    }
    
    private var addTextButton: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray4))
            Text("+T")
                .font(.title2.weight(.light))
        }
        .frame(width: 80, height: 80)
        .onTapGesture {
            editor.openTextEditor(isEdit: false, timeRange: video.rangeDuration)
        }
    }
}
