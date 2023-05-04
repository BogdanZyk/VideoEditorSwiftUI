//
//  AudioEntity+Ext.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 04.05.2023.
//

import Foundation
import CoreData


extension AudioEntity{
    
    
    var audioModel: Audio?{
        guard let urlStr = url, let url = URL(string: urlStr) else { return nil }
        return .init(url: url, duration: duration)
    }
    
    static func createAudio(context: NSManagedObjectContext, url: String, duration: Double) -> AudioEntity{
        let entity = AudioEntity(context: context)
        entity.duration = duration
        entity.url = url
        return entity
    }
}
