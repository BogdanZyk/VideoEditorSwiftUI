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
    
    @Published var tools = ToolsModel.allTools()
    @Published var currentVideo: Video?
    @Published var selectedTools: ToolsModel?
    @Published var resetCounter: Int = 0
    
    func setVideo(_ url: URL, geo: GeometryProxy){
        currentVideo = .init(url: url)
        currentVideo?.updateThumbnails(geo)
    }
 
    
    func udateRate(rate: Float){
        currentVideo?.updateRate(rate)
    }
    
    
    func setToolIsChange(_ isChange: Bool){
        guard let selectedTools,
                let index = tools.firstIndex(where: {$0.id == selectedTools.id}),
              self.selectedTools?.isChange != isChange else {return}
        tools[index].isChange = isChange
        self.selectedTools?.isChange = isChange
    }
  
    func reset(){
        guard let selectedTools else {return}
       
        switch selectedTools.tool{
            
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.setToolIsChange(false)
        }
    }
    
}



struct ThumbnailImage: Identifiable{
    var id: UUID = UUID()
    var image: Image?
}


