//
//  FiltersView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 26.04.2023.
//

import SwiftUI


struct FiltersView: View {
    @State var selectedFilterName: String? = nil
    @ObservedObject var viewModel: FiltersViewModel
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
    @StateObject static var vm = FiltersViewModel()
    static var previews: some View {
        FiltersView(selectedFilterName: nil, viewModel: vm, onChangeFilter: {_ in})
            .padding()
            .onAppear{
                vm.loadFilters(for: UIImage(named: "simpleImage")!)
            }
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
        Group{
            if let image = viewModel.image{
                imageView(image, isSelected: selectedFilterName == nil)
                    .onTapGesture {
                        selectedFilterName = nil
                    }
                    .padding(.trailing, 30)
            }
        }
    }
}


