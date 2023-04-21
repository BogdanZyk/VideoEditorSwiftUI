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

    
    var wrappedTools: [Int]{
        appliedTools?.components(separatedBy: ",").compactMap({Int($0)}) ?? []
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
        project.lowerBound = video.rangeDuration.lowerBound
        project.upperBound = video.rangeDuration.upperBound
        
        context.saveContext()
    }
    
    
    static func update(for video: Video, project: ProjectEntity){
        if let context = project.managedObjectContext {
            project.lowerBound = video.rangeDuration.lowerBound
            project.upperBound = video.rangeDuration.upperBound
            project.appliedTools = video.toolsApplied.map({String($0)}).joined(separator: ",")
            project.rotation = video.rotation
            project.rate = Double(video.rate)
            context.saveContext()
        }
    }
    
    static func remove(_ item: ProjectEntity){
        if let context = item.managedObjectContext{
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
