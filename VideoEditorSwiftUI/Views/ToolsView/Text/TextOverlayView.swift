//
//  TextOverlayView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 01.05.2023.
//

import SwiftUI

struct TextOverlayView: View {
    @ObservedObject var viewModel: TextEditorViewModel
    let onSet: ([TextBox]) -> Void
    var body: some View {
        ZStack{
            ForEach(viewModel.textBoxes) { textBox in
                let isSelected = viewModel.isSelected(textBox.id)
                VStack(alignment: .leading, spacing: 2) {
                    if isSelected{
                        textBoxButtons(textBox)
                    }
                   
                    Text(createAttr(textBox))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .overlay {
                            if isSelected{
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(.cyan)
                            }
                        }
                        .onTapGesture {
                            editOrSelectTextBox(textBox, isSelected)
                        }
                }
                .offset(textBox.offset)
                
                .gesture(DragGesture(minimumDistance: 1).onChanged({ value in
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
                        print(viewModel.textBoxes[getIndex(textBox.id)].offset)
                    }
                    onSet(viewModel.textBoxes)
                }))
            }
        }
        .allFrame()
        .contentShape(Rectangle())
        .gesture(MagnificationGesture()
            .onChanged({ value in
                if let box = viewModel.selectedTextBox{
                    let lastFontSize = viewModel.textBoxes[getIndex(box.id)].lastFontSize
                    viewModel.textBoxes[getIndex(box.id)].fontSize = (value * 10) + lastFontSize
                }
            }).onEnded({ value in
                if let box = viewModel.selectedTextBox{
                    viewModel.textBoxes[getIndex(box.id)].lastFontSize = value * 10
                }
                onSet(viewModel.textBoxes)
            }))
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




struct TextEditorView: View{
    @ObservedObject var viewModel: TextEditorViewModel
    @State private var textHeight: CGFloat = 100
    @State private var isFocused: Bool = true
    let onSave: ([TextBox]) -> Void
    var body: some View{
        Color.secondary.opacity(0.1)
                .ignoresSafeArea()
        VStack{
            Spacer()
            TextView(textBox: $viewModel.currentTextBox, isFirstResponder: $isFocused, minHeight: textHeight, calculatedHeight: $textHeight)
                .frame(maxHeight: textHeight)
            Spacer()
            
            Button {
                closeKeyboard()
                viewModel.saveTapped()
                onSave(viewModel.textBoxes)
            } label: {
                Text("Save")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            }
            .hCenter()
            .overlay(alignment: .leading) {
                HStack {
                    Button{
                        closeKeyboard()
                        viewModel.cancelTextEditor()
                    } label: {
                        Image(systemName: "xmark")
                            .padding(12)
                            .foregroundColor(.white)
                            .background(Color.secondary, in: Circle())
                    }
                    
                    Spacer()
                    HStack(spacing: 20){
                        ColorPicker(selection: $viewModel.currentTextBox.fontColor, supportsOpacity: true) {
                        }.labelsHidden()
                       
                        ColorPicker(selection: $viewModel.currentTextBox.bgColor, supportsOpacity: true) {
                        }.labelsHidden()
                    }
                }
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
    
    
    private func closeKeyboard(){
        isFocused = false
    }
}


class TextEditorViewModel: ObservableObject{
    
    @Published var textBoxes: [TextBox] = [.init(text: "Test")]
    @Published var showEditor: Bool = false
    @Published var currentTextBox: TextBox = TextBox()
    @Published var selectedTextBox: TextBox?

    
    private var isEditMode: Bool = false
    
    func cancelTextEditor(){
        showEditor = false
    }
    
    func selectTextBox(_ texBox: TextBox){
        selectedTextBox = texBox
    }
    
    func isSelected(_ id: UUID) -> Bool{
        selectedTextBox?.id == id
    }
    
    func removeTextBox(){
        guard let selectedTextBox else {return}
        textBoxes.removeAll(where: {$0.id == selectedTextBox.id})
    }
    
    func copy(_ textBox: TextBox){
        var new = textBox
        new.id = UUID()
        new.offset = .init(width: new.offset.width + 10, height: new.offset.height + 10)
        textBoxes.append(new)
    }
    
    func openTextEditor(isEdit: Bool, _ textBox: TextBox? = nil){
        if let textBox, isEdit{
            isEditMode = true
            currentTextBox = textBox
        }else{
            currentTextBox = TextBox()
            isEditMode = false
        }
        showEditor = true
    }
    
    func saveTapped(){
        if isEditMode{
            if let index = textBoxes.firstIndex(where: {$0.id == currentTextBox.id}){
                textBoxes[index] = currentTextBox
            }
        }else{
            textBoxes.append(currentTextBox)
        }
        selectedTextBox = currentTextBox
        cancelTextEditor()
    }
}


struct TextView: UIViewRepresentable {
    
    @Binding var isFirstResponder: Bool
    @Binding var textBox: TextBox

    var minHeight: CGFloat
    @Binding var calculatedHeight: CGFloat

    init(textBox: Binding<TextBox>, isFirstResponder: Binding<Bool>, minHeight: CGFloat, calculatedHeight: Binding<CGFloat>) {
        self._textBox = textBox
        self._isFirstResponder = isFirstResponder
        self.minHeight = minHeight
        self._calculatedHeight = calculatedHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator

        // Decrease priority of content resistance, so content would not push external layout set in SwiftUI
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.text = self.textBox.text
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor.clear

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        
        focused(textView)
        recalculateHeight(view: textView)
        setTextAttrs(textView)
    
    }
    
    private func setTextAttrs(_ textView: UITextView){
        
        let attrStr = NSMutableAttributedString(string: textView.text)
        let range = NSRange(location: 0, length: attrStr.length)
        
        attrStr.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor(textBox.bgColor), range: range)
        attrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: textBox.fontSize, weight: .medium), range: range)
        attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(textBox.fontColor), range: range)
        
        textView.attributedText = attrStr
        textView.textAlignment = .center
    }

   private func recalculateHeight(view: UIView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if minHeight < newSize.height && $calculatedHeight.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = newSize.height // !! must be called asynchronously
            }
        } else if minHeight >= newSize.height && $calculatedHeight.wrappedValue != minHeight {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = self.minHeight // !! must be called asynchronously
            }
        }
    }
    
    private func focused(_ textView: UITextView){
        DispatchQueue.main.async {
            switch isFirstResponder {
            case true: textView.becomeFirstResponder()
            case false: textView.resignFirstResponder()
            }
        }
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textViewDidChange(_ textView: UITextView) {
            if textView.markedTextRange == nil {
                parent.textBox.text = textView.text ?? String()
                parent.recalculateHeight(view: textView)
            }
        }
        
//        func textViewDidBeginEditing(_ textView: UITextView) {
//            parent.isFirstResponder = true
//        }
    }
}
