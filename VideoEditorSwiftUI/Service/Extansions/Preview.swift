//
//  Preview.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import CoreData
import SwiftUI

extension PreviewProvider {
    
    
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
    


    
}

class DeveloperPreview {
    
    static let instance = DeveloperPreview()
    private init() { }
    
    
    let contreller = PersistenceController(inMemory: true)
    
    var viewContext: NSManagedObjectContext {
        
         
        _ = projects
//
//        _ = accounts
//
        return contreller.viewContext
     }
    
//    var transactions: [TransactionEntity]{
//        let context = contreller.viewContext
//        let trans1 = TransactionEntity(context: context)
//        trans1.id = UUID().uuidString
//        trans1.createAt = Date.now
//        trans1.amount = 1300
//        trans1.currencyCode = "RUB"
//        trans1.type = TransactionType.income.rawValue
//        trans1.category = category[1]
        
    
    var projects: [ProjectEntity]{
        let context = contreller.viewContext
        let project1 = ProjectEntity(context: context)
        project1.id = UUID().uuidString
        project1.createAt = Date.now
        project1.url = "file:///Users/bogdanzykov/Library/Developer/CoreSimulator/Devices/86D65E8C-7D49-47AF-A511-BFA631289CB1/data/Containers/Data/Application/52E5EF3C-9E78-4676-B3EA-03BD22CCD09A/Documents/video_copy.mp4"
        
        return [project1]
    }

}
