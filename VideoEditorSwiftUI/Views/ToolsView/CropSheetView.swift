//
//  CropSheetView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import SwiftUI

struct CropSheetView: View {
    @ObservedObject var editorVM: EditorViewModel
    @State private var currentTab: Tab = .format
    var body: some View {
        VStack{
            tabButtons
            
            switch currentTab{
            case .format:
                EmptyView()
            case .rotate:
                rotateSection
            }
        }
    }
}

struct CropSheetView_Previews: PreviewProvider {
    static var previews: some View {
        CropSheetView(editorVM: EditorViewModel())
    }
}

extension CropSheetView{
    
    
    
    private var rotateSection: some View{
        Button {
            editorVM.rotate()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
    }
    
    
    private var tabButtons: some View{
        HStack{
            ForEach(Tab.allCases, id: \.self){tab in
                VStack(spacing: 0) {
                    Text(tab.rawValue.capitalized)
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    if currentTab == tab{
                        Rectangle()
                          .frame(height: 1)
                    }
                }
                .foregroundColor(tab == currentTab ? .white : .secondary)
                .hCenter()
                .onTapGesture {
                    currentTab = tab
                }
            }
        }
    }
    
    enum Tab: String, CaseIterable{
        case format, rotate
    }
    
}
