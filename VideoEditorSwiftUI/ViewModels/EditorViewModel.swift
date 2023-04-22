//
//  EditorViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import Foundation
import AVKit
import SwiftUI

class EditorViewModel: ObservableObject{
    
    @Published var currentVideo: Video?
    @Published var selectedTools: ToolEnum?
    @Published var resetCounter: Int = 0
    
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
    
    func createVideo(){
        guard let currentVideo else {return}
        let size = currentVideo.asset.tracks(withMediaType: .video)[0].naturalSize
        AssetHelper().applyVideoTransforms(asset: currentVideo.asset, originalDuration: currentVideo.originalDuration, rotationAngle: currentVideo.rotation, rate: currentVideo.rate, timeInterval: currentVideo.rangeDuration, mirror: currentVideo.isMirror, size: size) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure.localizedDescription)
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


