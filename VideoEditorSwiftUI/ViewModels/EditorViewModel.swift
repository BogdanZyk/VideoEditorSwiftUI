//
//  EditorViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import Foundation
import AVKit
import SwiftUI
import Photos

class EditorViewModel: ObservableObject{
    
    @Published var currentVideo: Video?
    @Published var selectedTools: ToolEnum?
    @Published var resetCounter: Int = 0
    @Published var showLoader: Bool = false
    @Published var showAlert: Bool = false
    
    private var projectEntity: ProjectEntity?
    

    func setNewVideo(_ url: URL, geo: GeometryProxy){
        currentVideo = .init(url: url)
        currentVideo?.updateThumbnails(geo)
        createProject()
    }
    
    func setProject(_ project: ProjectEntity, geo: GeometryProxy){
        projectEntity = project
        
        guard let url = project.videoURL else {return}
        
        currentVideo = .init(url: url, rangeDuration: project.lowerBound...project.upperBound, rate: Float(project.rate), rotation: project.rotation)
        currentVideo?.toolsApplied = project.wrappedTools 
        
        currentVideo?.updateThumbnails(geo)
    }
    
    private func renderVideo(_ videoQuality: VideoQuality, completion: @escaping (URL) -> Void){
        guard let currentVideo, !showLoader else {return}
        showLoader = true
        VideoEditor().renderVideo(asset: currentVideo.asset, originalDuration: currentVideo.originalDuration, rotationAngle: currentVideo.rotation, rate: currentVideo.rate, timeInterval: currentVideo.rangeDuration, mirror: currentVideo.isMirror, videoQuality: videoQuality) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    completion(success)
                    self.showLoader = false
                    print(success)
                case .failure(let failure):
                    print(failure.localizedDescription)
                    self.showLoader = false
                }
            }
        }
    }
    
    func saveVideo(for videoQuality: VideoQuality){
        renderVideo(videoQuality){url in
            self.saveVideoInLib(url)
        }
    }
    
    func shareVideo(for videoQuality: VideoQuality){
        renderVideo(videoQuality){url in
            self.showShareSheet(data: [url])
        }
    }
    
    
    private func showShareSheet(data: Any){
        UIActivityViewController(activityItems: [data], applicationActivities: nil).presentInKeyWindow()
    }
    
    private func saveVideoInLib(_ url: URL){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                DispatchQueue.main.async {
                    self.showAlert = true
                }
//                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(defaultAction)
//                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
        
}

//MARK: - Core data logic
extension EditorViewModel{
    
    private func createProject(){
        guard let currentVideo else { return }
        let context = PersistenceController.shared.viewContext
        ProjectEntity.create(video: currentVideo, context: context)
    }
    
    func updateProject(){
        guard let projectEntity, let currentVideo else { return }
        ProjectEntity.update(for: currentVideo, project: projectEntity)
    }
}

//MARK: - Tools logic
extension EditorViewModel{
    
    func updateRate(rate: Float){
        currentVideo?.updateRate(rate)
        setTools()
    }
    
    func rotate(){
        currentVideo?.rotate()
        setTools()
    }
    
    func toggleMirror(){
        currentVideo?.isMirror.toggle()
        setTools()
    }
    
    func setTools(){
        guard let selectedTools else { return }
        currentVideo?.appliedTool(for: selectedTools)
    }
  
    func reset(){
        guard let selectedTools else {return}
       
        switch selectedTools{
            
        case .cut:
            currentVideo?.resetRangeDuration()
        case .speed:
            currentVideo?.resetRate()
        case .crop:
            break
        case .audio:
            break
        case .text:
            break
        case .filters:
            break
        case .corrections:
            break
        case .frames:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.currentVideo?.removeTool(for: selectedTools)
        }
    }
}


