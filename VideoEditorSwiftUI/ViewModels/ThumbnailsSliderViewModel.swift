//
//  ThumbnailsSliderViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import AVKit
import SwiftUI

class ThumbnailsSliderViewModel: ObservableObject{
    
    @Published var thumbnailsImages = [ThumbnailImage]()
    @Published var trimRange: ClosedRange<Double> = 0...0.1
    var asset: AVAsset?
    
    
    var duration: ClosedRange<Double>{
        0...(asset?.videoDuration() ?? 0.1)
    }
    
    func updateThumbnails(url: URL, geo: GeometryProxy){
        
        let asset = AVAsset(url: url)
        self.asset = asset
        let duration = asset.videoDuration()
        
        thumbnailsImages.removeAll()
        
        let imagesCount = thumbnailCount(geo)
        
        var offset: Float64 = 0
        for i in 0..<imagesCount{
            let thumbnailImage = ThumbnailImage(image: asset.getImage(Int(offset)))
            offset = Double(i) * (duration / Double(imagesCount))
            thumbnailsImages.append(thumbnailImage)
        }
        
        trimRange = 0...asset.videoDuration()
    }
    

    private func thumbnailCount(_ geo: GeometryProxy) -> Int {
        
        let num = Double(geo.size.width) / Double(geo.size.height / 1.5)
        
        return Int(ceil(num))
    }
}


struct ThumbnailImage: Identifiable{
    var id: UUID = UUID()
    var image: Image?
}
