//
//  CoreDataManager.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import Foundation
import CoreData

struct CoreDataManager {
    
    let mainContext: NSManagedObjectContext
    
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    
    
    func fetchProjects() -> [ProjectEntity] {
        let fetchRequest = ProjectEntity.request()
    
        do {
            let projects = try mainContext.fetch(fetchRequest)
            return projects
        } catch let error {
            print("Failed to fetch FoodEntity: \(error)")
        }
        return []
    }
    
}

//MARK: - Account
extension CoreDataManager{
    
    
//    func updateAccount(account: AccountEntity){
//        AccountEntity.updateAccount(for: account)
//    }
//
//    func createAccount(title: String, currencyCode: String, color: String, balance: Double, members: Set<UserEntity>) -> AccountEntity{
//        AccountEntity.create(title: title, currencyCode: currencyCode, balance: balance, color: color, members: members, context: mainContext)
//    }

}

