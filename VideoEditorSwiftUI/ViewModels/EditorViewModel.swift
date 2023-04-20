//
//  EditorViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import Foundation
import AVKit
import SwiftUI

final class EditorViewModel: ObservableObject{
    
    @Published var currentVideo: Video?
    @Published var toolState: ToolEnum?
    
    
    func setVideo(_ url: URL, geo: GeometryProxy){
        currentVideo = .init(url: url)
        currentVideo?.updateThumbnails(geo)
    }
 
    
    func udateRate(rate: Float){
        currentVideo?.updateRate(rate)
    }
  
    func reset(){
        guard let toolState else {return}
        switch toolState{
            
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
    }
    
}



struct ThumbnailImage: Identifiable{
    var id: UUID = UUID()
    var image: Image?
}


