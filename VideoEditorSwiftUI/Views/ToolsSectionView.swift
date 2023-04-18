//
//  ToolsSectionView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct ToolsSectionView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        VStack{
            LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                ForEach(ToolEnum.allCases, id: \.self) { tool in
                    ToolButtonView(label: tool.title, image: tool.image) {
                        
                    }
                }
            }
        }
    }
}

struct ToolsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsSectionView()
    }
}
