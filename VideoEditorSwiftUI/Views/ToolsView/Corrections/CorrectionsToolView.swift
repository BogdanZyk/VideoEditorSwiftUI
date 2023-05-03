//
//  CorrectionsToolView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 26.04.2023.
//

import SwiftUI

struct CorrectionsToolView: View {
    @State var currentTab: CorrectionType = .brightness
    @Binding var correction: ColorCorrection
    let onChange: (ColorCorrection) -> Void
    var body: some View {
        VStack(spacing: 20){
            
            HStack{
                ForEach(CorrectionType.allCases, id: \.self) { type in
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
        CorrectionsToolView(correction: .constant(Video.mock.colorCorrection), onChange: {_ in})
    }
}


extension CorrectionsToolView{
    
   
    
    private var slider: some View{
        
        let value = getValue(currentTab)
            
        return VStack {
            Text(String(format: "%.1f",  value.wrappedValue))
                .font(.subheadline)
            Slider(value: value, in: -1...1) { change in
                if !change{
                    onChange(correction)
                }
            }
            .tint(Color.white)
        }
    }
    
    func getValue(_ type: CorrectionType) -> Binding<Double>{
        switch type {
        case .brightness:
            return $correction.brightness
        case .contrast:
            return $correction.contrast
        case .saturation:
            return $correction.saturation
        }
    }
}
