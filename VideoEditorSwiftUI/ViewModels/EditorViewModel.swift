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
    
    func setVideo(_ url: URL, geo: GeometryProxy){
        currentVideo = .init(url: url)
        currentVideo?.updateThumbnails(geo)
    }
 
  
    
}



struct ThumbnailImage: Identifiable{
    var id: UUID = UUID()
    var image: Image?
}


