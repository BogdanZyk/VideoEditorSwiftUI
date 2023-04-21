//
//  CropSheetView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import SwiftUI

struct CropSheetView: View {
    @State var rotateValue: Double = 0
    @ObservedObject var editorVM: EditorViewModel
    @State private var currentTab: Tab = .rotate
    var body: some View {
        VStack(spacing: 40){
            tabButtons
            Group{
                switch currentTab{
                case .format:
                    EmptyView()
                case .rotate:
                    rotateSection
                }
            }
        }
        .onAppear{
            rotateValue = editorVM.currentVideo?.rotation ?? 0
        }
        .onChange(of: editorVM.currentVideo?.rotation) { newValue in
            rotateValue = newValue ?? 0
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
        
        
        HStack(spacing: 30){
            
            CustomSlider(value: $rotateValue,
                         in: 0...360,
                         step: 90,
                         onEditingChanged: { started in
                if !started{
                    editorVM.currentVideo?.rotation = rotateValue
                    editorVM.setTools()
                }
            }, track: {
                Capsule()
                    .foregroundColor(.secondary)
                    .frame(width: 200, height: 5)
            }, thumb: {
                Circle()
                    .foregroundColor(.white)
                    .shadow(radius: 20 / 1)
            }, thumbSize: CGSize(width: 20, height: 20))
            
            
            Button {
                editorVM.rotate()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.plain)
            
            Button {
                editorVM.toggleMirror()
            } label: {
                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
                    .foregroundColor((editorVM.currentVideo?.isMirror ?? false) ? .secondary : .white)
            }
            .buttonStyle(.plain)
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
