//
//  CorrectionsToolView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 26.04.2023.
//

import SwiftUI

struct CorrectionsToolView: View {
    @State var currentTab: CorrectionFilter.CorrectionType = .brightness
    @ObservedObject var viewModel: FiltersViewModel
    let onChange: (CIFilter?) -> Void
    var body: some View {
        VStack(spacing: 50){
            
            HStack{
                ForEach(CorrectionFilter.CorrectionType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .font(.subheadline)
                        .hCenter()
                        .foregroundColor(currentTab == type ? .white : .secondary)
                        .onTapGesture {
                            currentTab = type
                        }
                }
            }
            slider
        }
    }
}

struct CorrectionsToolView_Previews: PreviewProvider {
    static var previews: some View {
        CorrectionsToolView(viewModel: FiltersViewModel(), onChange: {_ in})
    }
}


extension CorrectionsToolView{
    
    @ViewBuilder
    private var slider: some View{
        
        if let index = viewModel.corrections.firstIndex(where: {$0.type == currentTab}){
            let correction = $viewModel.corrections[index]
            
            CustomSlider(value: correction.value,
                         in: -1...1,
                         step: 0.1,
                         onEditingChanged: { change in
                if !change{
                    viewModel.updateColorFilter(correction.wrappedValue)
                    onChange(viewModel.colorCorrectionFilter)
                }
            }, track: {
                Capsule()
                    .foregroundColor(.secondary)
                    .frame(width: 300, height: 2)
            }, thumb: {
                
                ZStack{
                    Text(String(format: "%.1f",  correction.value.wrappedValue))
                        .font(.footnote)
                        .frame(width: 30)
                        .offset(y: -25)
                    Circle()
                        .foregroundColor(.white)
                }
                
            }, thumbSize: CGSize(width: 20, height: 20))
        }
    }
    
}
