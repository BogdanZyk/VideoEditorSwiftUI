//
//  RootViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import Foundation
import CoreData
import PhotosUI
import SwiftUI

final class RootViewModel: ObservableObject{
    
    @Published var projects = [ProjectEntity]()
    private let dataManager: CoreDataManager
    
    
    init(mainContext: NSManagedObjectContext){
        self.dataManager = CoreDataManager(mainContext: mainContext)
    }
    
    func fetch(){
        projects = dataManager.fetchProjects()
    }
    
    func removeProject(_ project: ProjectEntity){
        ProjectEntity.remove(project)
        fetch()
    }
}
