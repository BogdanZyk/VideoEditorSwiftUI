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
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: image)
                    .imageScale(.medium)
                Text(label)
                    .font(.footnote)
            }
            .frame(height: 65)
            .hCenter()
            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ToolButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ToolButtonView(label: "Cut", image: "scissors"){}
            .padding()
    }
}
