//
//  VideoEditorSwiftUIApp.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import SwiftUI

@main
struct VideoEditorSwiftUIApp: App {
    @StateObject var rootVM = RootViewModel(mainContext: PersistenceController.shared.viewContext)
    var body: some Scene {
        WindowGroup {
            RootView(rootVM: rootVM)
                .preferredColorScheme(.dark)
        }
    }
}
