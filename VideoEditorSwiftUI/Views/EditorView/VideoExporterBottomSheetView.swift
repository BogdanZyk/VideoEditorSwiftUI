//
//  VideoExporterBottomSheetView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 24.04.2023.
//

import SwiftUI

struct VideoExporterBottomSheetView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: ExporterViewModel
    
    init(isPresented: Binding<Bool>, video: Video) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ExporterViewModel(video: video))
    }
    var body: some View {
        SheetView(isPresented: $isPresented, bgOpacity: 0.1) {
            VStack(alignment: .leading){
                
                switch viewModel.renderState{
                case .unknown:
                    list
                case .failed:
                    Text("Failed")
                case .loading, .loaded:
                    loadingView
                case .saved:
                    saveView
                }
            }
            .hCenter()
            .frame(height: getRect().height / 2.8)
        }
        .ignoresSafeArea()
        .alert("Save video", isPresented: $viewModel.showAlert) {}
        .disabled(viewModel.renderState == .loading)
        .animation(.easeInOut, value: viewModel.renderState)
    }
}

struct VideoQualityPopapView2_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom){
            Color.secondary.opacity(0.5)
            VideoExporterBottomSheetView(isPresented: .constant(true), video: Video.mock)
        }
    }
}

extension VideoExporterBottomSheetView{
    
    
    private var list: some View{
        Group{
            qualityListSection
            
            HStack {
                saveButton
                shareButton
            }
            .padding(.top, 10)
        }
    }
    
    private var loadingView: some View{
        VStack(spacing: 30){
            ProgressView()
                .scaleEffect(2)
            Text(viewModel.progressTimer.formatted())
            Text("Video export in progress")
                .font(.headline)
            Text("Do not close the app or lock the screen")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    
    private var saveView: some View{
        VStack(spacing: 30){
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40, weight: .light))
            Text("Video saved")
                .font(.title2.bold())
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                viewModel.renderState = .unknown
            }
        }
    }
    
    private var qualityListSection: some View{
        ForEach(VideoQuality.allCases.reversed(), id: \.self) { type in
            
            HStack{
                VStack(alignment: .leading) {
                    Text(type.title)
                        .font(.headline)
                    Text(type.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if let value = type.calculateVideoSize(duration: viewModel.video.totalDuration){
                    Text(String(format: "%.1fMb", value))
                }
            }
            .padding(10)
            .hLeading()
            .background{
                if viewModel.selectedQuality == type{
                    RoundedRectangle(cornerRadius: 10)
                        .fill( Color(.systemGray5))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectedQuality = type
            }
        }
    }
    
    
    private var saveButton: some View{
        Button {
            mainAction(.save)
        } label: {
            buttonLabel("Save", icon: "square.and.arrow.down")
        }
        .hCenter()
    }
    
    private var shareButton: some View{
        Button {
            mainAction(.share)
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
    
    
    private func mainAction(_ action: ExporterViewModel.ActionEnum){
        Task{
           await viewModel.action(action)
        }
    }

}







extension UIViewController {
    
    func presentInKeyWindow(animated: Bool = true, completion: (() -> Void)? = nil) {
        UIApplication.shared.windows.last { $0.isKeyWindow }?.rootViewController?
            .present(self, animated: animated, completion: completion)
    }
}
