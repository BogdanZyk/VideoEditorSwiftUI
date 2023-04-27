//
//  ExporterViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 24.04.2023.
//

import Foundation
import Combine
import Photos
import UIKit

class ExporterViewModel: ObservableObject{
    
    let video: Video
    
    @Published var renderState: ExportState = .unknown
    @Published var showAlert: Bool = false
    @Published var selectedQuality: VideoQuality = .medium
    private var cancellable = Set<AnyCancellable>()
    private var action: ActionEnum = .save
    
    init(video: Video){
        self.video = video
        startRenderStateSubs()
    }
    
    
    deinit{
        cancellable.forEach({$0.cancel()})
    }
    
    
    private func renderVideo(){
        
        renderState = .loading
        VideoEditor().startRender(video: video, videoQuality: selectedQuality)
         {[weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self.renderState = .loaded(url)
                    print(url)
                case .failure(let failure):
                    print(failure.localizedDescription)
                    self.renderState = .failed
                }
            }
        }
    }
    
    
    func action(_ action: ActionEnum){
        self.action = action
        renderVideo()
    }

    func startRenderStateSubs(){
        $renderState
            .sink {[weak self] state in
                guard let self = self else {return}
                switch state {
                case .loaded(let url):
                    if self.action == .save{
                        self.saveVideoInLib(url)
                    }else{
                        self.showShareSheet(data: url)
                    }
                default:
                    break
                }
            }
            .store(in: &cancellable)
    }
    
    
    private func showShareSheet(data: Any){
        DispatchQueue.main.async {
            self.renderState = .unknown
        }
        UIActivityViewController(activityItems: [data], applicationActivities: nil).presentInKeyWindow()
    }
    
    private func saveVideoInLib(_ url: URL){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) {[weak self] saved, error in
            guard let self = self else {return}
            if saved {
                DispatchQueue.main.async {
                    self.renderState = .saved
                }
            }
        }
    }
    
    enum ActionEnum: Int{
        case save, share
    }
    
    
    
    enum ExportState: Identifiable, Equatable {
        case unknown, loading, loaded(URL), failed, saved
        
        var id: Int{
            switch self {
            case .unknown: return 0
            case .loading: return 1
            case .loaded: return 2
            case .failed: return 3
            case .saved: return 4
            }
        }
    }
    
}
