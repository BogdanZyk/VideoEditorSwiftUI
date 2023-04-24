//
//  VideoQualityBottomSheetView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 24.04.2023.
//

import SwiftUI

struct VideoQualityBottomSheetView: View {
    @Binding var isPresented: Bool
    @State var selectedQuality: VideoQuality = .medium
    @ObservedObject var editorVM: EditorViewModel
    var body: some View {
        SheetView(isPresented: $isPresented) {
            VStack(alignment: .leading){
                qualityListSection
                
                HStack {
                    saveButton
                    shareButton
                }
                .padding(.top, 10)
            }
        }
        .ignoresSafeArea()
        .disabled(editorVM.showLoader)
        .overlay{
            if editorVM.showLoader{
                ProgressView()
            }
        }
        .alert("Save video", isPresented: $editorVM.showAlert) {
            
        }
    }
}

struct VideoQualityPopapView2_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom){
            Color.secondary.opacity(0.5)
            VideoQualityBottomSheetView(isPresented: .constant(true), editorVM: EditorViewModel())
        }
    }
}

extension VideoQualityBottomSheetView{
    private var qualityListSection: some View{
        ForEach(VideoQuality.allCases.reversed(), id: \.self) { type in
            
            HStack{
                VStack(alignment: .leading) {
                    Text(type.title)
                        .font(.headline)
                    Text("subtitle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if let video = editorVM.currentVideo, let value = type.calculateVideoSize(duration: video.totalDuration){
                    Text(String(format: "%.1fMb", value))
                }
                
            }
            
            .padding(10)
            .hLeading()
            .background{
                if selectedQuality == type{
                    RoundedRectangle(cornerRadius: 10)
                        .fill( Color(.systemGray5))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedQuality = type
            }
            Divider()
        }
    }
    
    
    private var saveButton: some View{
        Button {
            editorVM.saveVideo(for: selectedQuality)
            
        } label: {
            buttonLabel("Save", icon: "square.and.arrow.down")
        }
        .hCenter()
    }
    
    private var shareButton: some View{
        Button {
            editorVM.shareVideo(for: selectedQuality)
        } label: {
            buttonLabel("Share", icon: "square.and.arrow.up")
        }
        .hCenter()
    }
    
    private func buttonLabel(_ label: String, icon: String) -> some View{
        
        VStack{
            Image(systemName: icon)
                .imageScale(.large)
                .padding(10)
                .background(Color(.systemGray), in: Circle())
            Text(label)
        }
        .foregroundColor(.white)
    }
    

}







extension UIViewController {
    
    func presentInKeyWindow(animated: Bool = true, completion: (() -> Void)? = nil) {
        UIApplication.shared.windows.last { $0.isKeyWindow }?.rootViewController?
            .present(self, animated: animated, completion: completion)
    }
}
