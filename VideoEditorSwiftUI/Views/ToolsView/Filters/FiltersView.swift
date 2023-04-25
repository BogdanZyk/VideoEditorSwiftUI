//
//  FiltersView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 26.04.2023.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FiltersView: View {
    @StateObject var viewModel: FiltersViewModel
    
    init(image: UIImage, filter: String? = nil, onChangeFilter: @escaping (CIFilter?) -> Void) {
        self._viewModel = StateObject(wrappedValue: FiltersViewModel(image: image, filterName: filter))
        self.onChangeFilter = onChangeFilter
    }
    
    let onChangeFilter: (CIFilter?) -> Void
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 5) {
                resetButton
                ForEach(viewModel.images) { filterImage in
                    imageView(filterImage.image, isSelected: filterImage.filter.name == viewModel.selectedFilter?.name)
                        .onTapGesture {
                            viewModel.selectedFilter = filterImage.filter
                            onChangeFilter(filterImage.filter)
                        }
                }
            }
            .frame(height: 60)
            .padding(.horizontal)
        }
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView( image: UIImage(named: "simpleImage")!, onChangeFilter: {_ in})
    }
}

extension FiltersView{
    private func imageView(_ uiImage: UIImage, isSelected: Bool) -> some View{
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 55, height: 55)
            .clipped()
            .border(.white, width: isSelected ? 2 : 0)
//            .background{
//                Rectangle()
//                    .frame(width: 70, height: 70)
//                    .border(Color.white)
//            }
    }
    
    
    private var resetButton: some View{
        imageView(viewModel.image, isSelected: viewModel.selectedFilter == nil)
            .onTapGesture {
                viewModel.selectedFilter = nil
                onChangeFilter(nil)
            }
            .padding(.trailing, 30)
    }
}

class FiltersViewModel: ObservableObject{
    
    @Published var images = [FilteredImage]()
    
    @Published var selectedFilter: CIFilter?
    
    @Published var value: Double = 1.0
    
    let image: UIImage
    
    init(image: UIImage, filterName: String? = nil){
        self.image = image
        if let filterName{
            self.selectedFilter = CIFilter(name: filterName)
        }
        load(for: image)
    }
    
    let filters: [CIFilter] = [
        
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
    
    func load(for image: UIImage){
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
    
//    func updateEffect(){
//        let context = CIContext()
//        filters.forEach { filter in
//            DispatchQueue.global(qos: .userInteractive).async {
//
//                guard let CiImage = CIImage(image: image) else {return}
//                filter.setValue(CiImage, forKey: kCIInputImageKey)
//
//                guard let newImage = filter.outputImage, let cgImage = context.createCGImage(newImage, from: CiImage.extent) else {return}
//
//                let filterImage = FilteredImage(image: UIImage(cgImage: cgImage), filter: filter)
//
//                DispatchQueue.main.async {
//                    self.images.append(filterImage)
//                }
//            }
//        }
//    }
}
