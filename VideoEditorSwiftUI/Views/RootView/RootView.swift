//
//  RootView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import SwiftUI
import PhotosUI

struct RootView: View {
    @State private var item: PhotosPickerItem?
    @State private var selectedVideoURL: URL?
    @State private var showEditor: Bool = false
    let columns = [
        GridItem(.adaptive(minimum: 150)),
        GridItem(.adaptive(minimum: 150)),
    ]
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        Text("My projects")
                            .font(.headline)
                        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                            newProjectButton
                            ForEach(1...5, id: \.self) { index in
                                Text("\(index)")
                                    .hCenter()
                                    .frame(height: 150)
                                    .background(Color.secondary, in: RoundedRectangle(cornerRadius: 5))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $showEditor){
                MainEditorView(videoURl: selectedVideoURL)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Video editor")
                        .font(.title2.bold())
                }
            }
            .onChange(of: item) { newItem in
                Task {
                    if let video = try await newItem?.loadTransferable(type: VideoItem.self) {
                        selectedVideoURL = video.url
                        try await Task.sleep(for: .milliseconds(50))
                        showEditor.toggle()
                        
                    } else {
                        print("Failed load video")
                    }
                }
            }
        }
    }
}

struct RootView_Previews2: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

extension RootView{
    
    
    private var newProjectButton: some View{
        
        PhotosPicker(selection: $item, matching: .videos) {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                Text("New project")
            }
            .hCenter()
            .frame(height: 150)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 5))
            .foregroundColor(.white)
        }
    }
        
    
}
