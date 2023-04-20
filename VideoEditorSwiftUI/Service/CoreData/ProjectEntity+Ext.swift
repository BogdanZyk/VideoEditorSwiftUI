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
        return URL(string: url)
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
        project.id = UUID().uuidString
        project.createAt = Date.now
        project.url = video.url.absoluteString
        project.rotation = video.rotation
        project.rate = Double(video.rate)
        project.lowerBound = video.rangeDuration.lowerBound
        project.upperBound = video.rangeDuration.upperBound
        
        context.saveContext()
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
