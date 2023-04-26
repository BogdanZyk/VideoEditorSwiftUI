//
//  CorrectionsToolView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 26.04.2023.
//

import SwiftUI

struct CorrectionsToolView: View {
    @ObservedObject var viewModel: FiltersViewModel
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CorrectionsToolView_Previews: PreviewProvider {
    static var previews: some View {
        CorrectionsToolView(viewModel: FiltersViewModel())
    }
}

