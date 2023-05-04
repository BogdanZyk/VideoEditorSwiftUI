//
//  ProjectEntity+Ext.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import Foundation
import CoreData
import SwiftUI


extension ProjectEntity{
    
    
    
    var videoURL: URL?{
        guard let url else {return nil}
        return FileManager().createVideoPath(with: url)
    }

    
    var wrappedTextBoxes: [TextBox]{
        wrappedBoxes.compactMap { entity -> TextBox? in
            if let text = entity.text, let bgColor = entity.bgColor,
               let fontColor = entity.fontColor{
                return .init(text: text, fontSize: entity.fontSize, bgColor: Color(hex: bgColor), fontColor: Color(hex: fontColor), timeRange: (entity.lowerTime...entity.upperTime), offset: .init(width: entity.offsetX, height: entity.offsetY))
            }
            return nil
        }
    }


    private var wrappedBoxes: Set<TextBoxEntity> {
        get { (textBoxes as? Set<TextBoxEntity>) ?? [] }
        set { textBoxes = newValue as NSSet }
    }
    
    var wrappedTools: [Int]{
        appliedTools?.components(separatedBy: ",").compactMap({Int($0)}) ?? []
    }
    
    var wrappedColor: Color{
        guard let frameColor else { return .blue }
        return Color(hex: frameColor)
    }
    
    var uiImage: UIImage{
        if let id, let uImage = FileManager().retrieveImage(with: id){
            return uImage
        }else{
            return UIImage(systemName: "exclamationmark.circle")!
        }
    }
    
    
    static func request() -> NSFetchRequest<ProjectEntity> {
        let request = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createAt", ascending: true)]
        return request
    }
    
    
  static func createTextBoxes(context: NSManagedObjectContext, boxes: [TextBox]) -> [TextBoxEntity]{
        
        boxes.map { box -> TextBoxEntity in
            let entity = TextBoxEntity(context: context)
            let offset = box.offset
            entity.text = box.text
            entity.bgColor = box.bgColor.toHex()
            entity.fontColor = box.fontColor.toHex()
            entity.fontSize = box.fontSize
            entity.lowerTime = box.timeRange.lowerBound
            entity.upperTime = box.timeRange.upperBound
            entity.offsetX = offset.width
            entity.offsetY = offset.height
            
            return entity
        }
        
    }
    
    
    static func create(video: Video, context: NSManagedObjectContext){
        let project = ProjectEntity(context: context)
        let id = UUID().uuidString
        if let image = video.thumbnailsImages.first?.image{
            FileManager.default.saveImage(with: id, image: image)
        }
        project.id = id
        project.createAt = Date.now
        project.url = video.url.lastPathComponent
        project.rotation = video.rotation
        project.rate = Double(video.rate)
        project.isMirror = video.isMirror
        project.filterName = video.filterName
        project.lowerBound = video.rangeDuration.lowerBound
        project.upperBound = video.rangeDuration.upperBound
        project.textBoxes = []
    
        context.saveContext()
    }
    
    
    static func update(for video: Video, project: ProjectEntity){
        if let context = project.managedObjectContext {
            project.isMirror = video.isMirror
            project.lowerBound = video.rangeDuration.lowerBound
            project.upperBound = video.rangeDuration.upperBound
            project.filterName = video.filterName
            project.saturation = video.colorCorrection.saturation
            project.contrast = video.colorCorrection.contrast
            project.brightness = video.colorCorrection.brightness
            project.appliedTools = video.toolsApplied.map({String($0)}).joined(separator: ",")
            project.rotation = video.rotation
            project.rate = Double(video.rate)
            project.frameColor = video.videoFrames?.frameColor.toHex()
            project.frameScale = video.videoFrames?.scaleValue ?? 0
            let boxes = createTextBoxes(context: context, boxes: video.textBoxes)
            project.wrappedBoxes = Set(boxes)
            
            if let audio = video.audio{
                project.audio = AudioEntity.createAudio(context: context,
                                             url: audio.url.absoluteString,
                                             duration: audio.duration)
            }else{
                project.audio = nil
            }
            
            context.saveContext()
        }
    }
    
    static func remove(_ item: ProjectEntity){
        if let context = item.managedObjectContext, let id = item.id, let url = item.url{
            let manager = FileManager.default
            manager.deleteImage(with: id)
            manager.deleteVideo(with: url)
            context.delete(item)
            context.saveContext()
        }
    }
    
}


extension NSManagedObjectContext {
    
    func saveContext (){
        if self.hasChanges {
            do{
                try self.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
