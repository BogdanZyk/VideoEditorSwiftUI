//
//  FiltersViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 26.04.2023.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class FiltersViewModel: ObservableObject{
    
    @Published var images = [FilteredImage]()
    @Published var colorCorrection = ColorCorrection()
    @Published var value: Double = 1.0
    
    var image: UIImage?
    
        
    private let filters: [CIFilter] = [
        
        .photoEffectChrome(),
        .photoEffectFade(),
        .photoEffectInstant(),
        .photoEffectMono(),
        .photoEffectNoir(),
        .photoEffectProcess(),
        .photoEffectTonal(),
        .photoEffectTransfer(),
        .sepiaTone(),
        .thermal(),
        .vignette(),
        .vignetteEffect(),
        .xRay(),
        .gaussianBlur()
        
    ]
    
    func loadFilters(for image: UIImage){
        self.image = image
        let context = CIContext()
        filters.forEach { filter in
            DispatchQueue.global(qos: .userInteractive).async {
                
                guard let CiImage = CIImage(image: image) else {return}
                filter.setValue(CiImage, forKey: kCIInputImageKey)
                
                guard let newImage = filter.outputImage, let cgImage = context.createCGImage(newImage, from: CiImage.extent) else {return}
                
                let filterImage = FilteredImage(image: UIImage(cgImage: cgImage), filter: filter)
                
                DispatchQueue.main.async {
                    self.images.append(filterImage)
                }
            }
        }
    }
}


