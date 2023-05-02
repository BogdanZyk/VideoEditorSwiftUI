//
//  TextOverlayView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 01.05.2023.
//

import SwiftUI

struct TextOverlayView: View {
    var currentTime: Double
    @ObservedObject var viewModel: TextEditorViewModel
    var disabledMagnification: Bool = false
    var body: some View {
        ZStack{
            if !disabledMagnification{
                Color.secondary.opacity(0.001)
                    .simultaneousGesture(MagnificationGesture()
                        .onChanged({ value in
                            if let box = viewModel.selectedTextBox{
                                let lastFontSize = viewModel.textBoxes[getIndex(box.id)].lastFontSize
                                viewModel.textBoxes[getIndex(box.id)].fontSize = (value * 10) + lastFontSize
                            }
                        }).onEnded({ value in
                            if let box = viewModel.selectedTextBox{
                                viewModel.textBoxes[getIndex(box.id)].lastFontSize = value * 10
                            }
                        }))
            }
            
            ForEach(viewModel.textBoxes) { textBox in
                let isSelected = viewModel.isSelected(textBox.id)
                
                if textBox.timeRange.contains(currentTime){
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if isSelected{
                            textBoxButtons(textBox)
                        }
                        
                        Text(createAttr(textBox))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .overlay {
                                if isSelected{
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(lineWidth: 1)
                                        .foregroundColor(.cyan)
                                }
                            }
                            .onTapGesture {
                                editOrSelectTextBox(textBox, isSelected)
                            }
                        
                    }
                    .offset(textBox.offset)
                    .simultaneousGesture(DragGesture(minimumDistance: 1).onChanged({ value in
                        guard isSelected else {return}
                        let current = value.translation
                        let lastOffset = textBox.lastOffset
                        let newTranslation: CGSize = .init(width: current.width + lastOffset.width, height: current.height + lastOffset.height)
                        
                        DispatchQueue.main.async {
                            viewModel.textBoxes[getIndex(textBox.id)].offset = newTranslation
                        }
                        
                    }).onEnded({ value in
                        guard isSelected else {return}
                        DispatchQueue.main.async {
                            viewModel.textBoxes[getIndex(textBox.id)].lastOffset = value.translation
                        }
                    }))
                }
            }
        }
        .allFrame()
    }
    
    private func createAttr(_ textBox: TextBox) -> AttributedString{
        var result = AttributedString(textBox.text)
        result.font = .systemFont(ofSize: textBox.fontSize, weight: .medium)
        result.foregroundColor = UIColor(textBox.fontColor)
        result.backgroundColor = UIColor(textBox.bgColor)
        return result
    }
}

struct TextOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView(selectedVideoURl: Video.mock.url)
    }
}


extension TextOverlayView{
    
    private func textBoxButtons(_ textBox: TextBox) -> some View{
        HStack(spacing: 10){
            Button {
                viewModel.removeTextBox()
            } label: {
                Image(systemName: "xmark")
                    .padding(5)
                    .background(Color(.systemGray2), in: Circle())
            }
            Button {
                viewModel.copy(textBox)
            } label: {
                Image(systemName: "doc.on.doc")
                    .imageScale(.small)
                    .padding(5)
                    .background(Color(.systemGray2), in: Circle())
            }
        }
        .foregroundColor(.white)
    }
    
    private func editOrSelectTextBox(_ textBox: TextBox, _ isSelected: Bool){
        if isSelected{
            viewModel.openTextEditor(isEdit: true, textBox)
        }else{
            viewModel.selectTextBox(textBox)
        }
    }
    
    private func getIndex(_ id: UUID) -> Int{
        let index = viewModel.textBoxes.firstIndex(where: {$0.id == id})
        return index ?? 0
    }
}











