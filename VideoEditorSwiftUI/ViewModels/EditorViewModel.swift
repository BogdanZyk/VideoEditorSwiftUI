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
import Combine

class EditorViewModel: ObservableObject{
    
    @Published var currentVideo: Video?
    @Published var selectedTools: ToolEnum?
    @Published var frames = VideoFrames()
    @Published var isSelectVideo: Bool = true
    
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
        currentVideo?.filterName = project.filterName
        currentVideo?.colorCorrection = .init(brightness: project.brightness, contrast: project.contrast, saturation: project.saturation)
        let frame = VideoFrames(scaleValue: project.frameScale, frameColor: project.wrappedColor)
        currentVideo?.videoFrames = frame
        self.frames = frame
        currentVideo?.updateThumbnails(geo)
        currentVideo?.textBoxes = project.wrappedTextBoxes
        if let audio = project.audio?.audioModel{
            currentVideo?.audio = audio
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
    
    
    func setFilter(_ filter: String?){
        currentVideo?.setFilter(filter)
        if filter != nil{
            setTools()
        }else{
            removeTool()
        }
    }
    
    
    func setText(_ textBox: [TextBox]){
        currentVideo?.textBoxes = textBox
        setTools()
    }
    
    func setFrames(){
        currentVideo?.videoFrames = frames
        setTools()
    }
    
    func setCorrections(_ correction: ColorCorrection){
        currentVideo?.colorCorrection = correction
        setTools()
    }
    
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
    
    func setAudio(_ audio: Audio){
        currentVideo?.audio = audio
        setTools()
    }
    
    func setTools(){
        guard let selectedTools else { return }
        currentVideo?.appliedTool(for: selectedTools)
    }
    
    func removeTool(){
        guard let selectedTools else { return }
        self.currentVideo?.removeTool(for: selectedTools)
    }
    
    func removeAudio(){
        guard let url = currentVideo?.audio?.url else {return}
        FileManager.default.removefileExists(for: url)
        currentVideo?.audio = nil
        isSelectVideo = true
        removeTool()
        updateProject()
    }
  
    func reset(){
        guard let selectedTools else {return}
       
        switch selectedTools{
            
        case .cut:
            currentVideo?.resetRangeDuration()
        case .speed:
            currentVideo?.resetRate()
        case .text, .audio, .crop:
            break
        case .filters:
            currentVideo?.setFilter(nil)
        case .corrections:
            currentVideo?.colorCorrection = ColorCorrection()
        case .frames:
            frames.reset()
            currentVideo?.videoFrames = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.removeTool()
        }
    }
}


