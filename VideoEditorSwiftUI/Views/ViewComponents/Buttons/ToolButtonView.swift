//
//  ToolButtonView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 18.04.2023.
//

import SwiftUI

struct ToolButtonView: View {
    let label: String
    let image: String
    let isChange: Bool
    let action: () -> Void
    
    
    private var bgColor: Color{
        Color(isChange ? .systemGray5 : .systemGray6)
    }
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: image)
                    .imageScale(.medium)
                Text(label)
                    .font(.caption)
            }
            .frame(height: 85)
            .hCenter()
            .background(bgColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ToolButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToolButtonView(label: "Cut", image: "scissors", isChange: false){}
            ToolButtonView(label: "Cut", image: "scissors", isChange: true){}
             
        }
        .frame(width: 100)
    }
}
