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
    @State var selectedFilterName: String? = nil
    @StateObject var viewModel: FiltersViewModel
    
    init(image: UIImage, filterName: String?, onChangeFilter: @escaping (String?) -> Void) {
        self.selectedFilterName = filterName
        self._viewModel = StateObject(wrappedValue: FiltersViewModel(image: image))
        self.onChangeFilter = onChangeFilter
    }
    
    let onChangeFilter: (String?) -> Void
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 5) {
                resetButton
                ForEach(viewModel.images.sorted(by: {$0.filter.name < $1.filter.name})) { filterImage in
                    imageView(filterImage.image, isSelected: selectedFilterName == filterImage.filter.name)
                        .onTapGesture {
                            selectedFilterName = filterImage.filter.name
                        }
                }
            }
            .frame(height: 60)
            .padding(.horizontal)
        }
        .onChange(of: selectedFilterName) { newValue in
            onChangeFilter(newValue)
        }
        .padding(.horizontal, -16)
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView(image: UIImage(named: "simpleImage")!, filterName: nil, onChangeFilter: {_ in})
            .padding()
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
    }
    
    
    private var resetButton: some View{
        imageView(viewModel.image, isSelected: selectedFilterName == nil)
            .onTapGesture {
                selectedFilterName = nil
            }
            .padding(.trailing, 30)
    }
}

class FiltersViewModel: ObservableObject{
    
    @Published var images = [FilteredImage]()
    
    @Published var value: Double = 1.0
    
    let image: UIImage
    
    init(image: UIImage, filterName: String? = nil){
        self.image = image
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
    
}
