//
//  Video.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 19.04.2023.
//

import SwiftUI
import AVKit

struct Video{
    
    var url: URL
    var asset: AVAsset
    let originalDuration: Double
    var rangeDuration: ClosedRange<Double>
    var thumbnailsImages = [ThumbnailImage]()
    var rate: Float = 1.0
    
    var totalDuration: Double{
        rangeDuration.upperBound - rangeDuration.lowerBound
    }
    
    init(url: URL){
        self.url = url
        self.asset = AVAsset(url: url)
        self.originalDuration = asset.videoDuration()
        self.rangeDuration = 0...originalDuration
    }
    
    init(url: URL, asset: AVAsset = AVAsset(), originalDuration: Double, rangeDuration: ClosedRange<Double>,  thumbnailsImages: [ThumbnailImage] = []){
        self.url = url
        self.asset = asset
        self.originalDuration = originalDuration
        self.rangeDuration = rangeDuration
        self.thumbnailsImages = thumbnailsImages
    }
    
    mutating func updateThumbnails(_ geo: GeometryProxy){
        let imagesCount = thumbnailCount(geo)
        
        var offset: Float64 = 0
        for i in 0..<imagesCount{
            let thumbnailImage = ThumbnailImage(image: asset.getImage(Int(offset)))
            offset = Double(i) * (originalDuration / Double(imagesCount))
            thumbnailsImages.append(thumbnailImage)
        }
    }
    
    ///reset and update
    mutating func updateRate(_ rate: Float){
       
        let lowerBound = (rangeDuration.lowerBound * Double(self.rate)) / Double(rate)
        let upperBound = (rangeDuration.upperBound *  Double(self.rate)) / Double(rate)
        rangeDuration = lowerBound...upperBound
        
        self.rate = rate
    }
    
    mutating func resetRangeDuration(){
        self.rangeDuration = 0...originalDuration
    }
    
    mutating func resetRate(){
        updateRate(1.0)
    }
    
    private func thumbnailCount(_ geo: GeometryProxy) -> Int {
        
        let num = Double(geo.size.width - 32) / Double(70 / 1.5)
        
        return Int(ceil(num))
    }
    
    
    static var mock: Video = .init(url:URL(string: "https://www.google.com/")!, asset: AVAsset(url: URL(string: "https://www.google.com/")!), originalDuration: 250, rangeDuration: 0...250)
}
