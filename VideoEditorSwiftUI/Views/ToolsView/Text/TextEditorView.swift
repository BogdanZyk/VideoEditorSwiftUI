//
//  TextEditorView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 02.05.2023.
//

import SwiftUI

struct TextEditorView: View{
    @ObservedObject var viewModel: TextEditorViewModel
    @State private var textHeight: CGFloat = 100
    @State private var isFocused: Bool = true
    let onSave: ([TextBox]) -> Void
    var body: some View{
        Color.black.opacity(0.35)
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
                    .opacity(viewModel.currentTextBox.text.isEmpty ? 0.5 : 1)
                    .disabled(viewModel.currentTextBox.text.isEmpty)
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
struct TextEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorView(viewModel: TextEditorViewModel(), onSave: {_ in})
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
