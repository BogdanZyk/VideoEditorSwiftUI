//
//  RootViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import Foundation
import AVKit
import SwiftUI

final class RootViewModel: ObservableObject{
    
    
    var asset: AVAsset?
    @Published var thumbnailsImages = [ThumbnailImage]()
    
    
    func setAsset(_ url: URL){
        asset = AVAsset(url: url)
    }
    
    
    
//    private func prepairImages(){
//        guard let asset else { return }
//        let seconds = asset.duration.seconds.splitDuration()
//        videoTrimImages = seconds.compactMap({.init(time: $0, image: asset.getImage($0))})
//    }
    
    
    
    func updateThumbnails(geo: GeometryProxy){
        
        guard let duration = asset?.videoDuration() else { return }
        
        thumbnailsImages.removeAll()
        
        let imagesCount = thumbnailCount(geo: geo)
        
        var offset: Float64 = 0
        for i in 0..<imagesCount{
            let thumbnailImage = ThumbnailImage(time: offset, image: asset?.getImage(Int(offset)))
            offset = Double(i) * (duration / Double(imagesCount))
            thumbnailsImages.append(thumbnailImage)
        }
    }
    

    private func thumbnailCount(geo: GeometryProxy) -> Int {
        
        let num = Double(geo.size.width) / Double(geo.size.height)
        
        return Int(ceil(num))
    }
    

}

struct ThumbnailImage: Identifiable{
    var id: UUID = UUID()
    var time: Double
    var image: Image?
}

extension Double{
    
    func splitDuration() -> [Double] {
        (1...Int(self)).map({Double($0)})
    }

}


extension AVAsset{
    
    func videoDuration() -> Double{
        self.duration.seconds
    }
}
