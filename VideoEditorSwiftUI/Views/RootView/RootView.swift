//
//  RootView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import SwiftUI
import PhotosUI

struct RootView: View {
    @ObservedObject var rootVM: RootViewModel
    @State private var item: PhotosPickerItem?
    @State private var selectedVideoURL: URL?
    @State private var showLoader: Bool = false
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
                            
                            ForEach(rootVM.projects) { project in
                                
                                NavigationLink {
                                    MainEditorView(project: project)
                                } label: {
                                    cellView(project)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $showEditor){
                MainEditorView(selectedVideoURl: selectedVideoURL)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Video editor")
                        .font(.title2.bold())
                }
            }
            .onChange(of: item) { newItem in
                loadPhotosItem(newItem)
            }
            .onAppear{
                rootVM.fetch()
            }
            .overlay {
                if showLoader{
                    Color.secondary.opacity(0.2).ignoresSafeArea()
                    VStack(spacing: 10){
                        Text("Loading video")
                        ProgressView()
                    }
                    .padding()
                    .frame(height: 100)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

struct RootView_Previews2: PreviewProvider {
    static var previews: some View {
        RootView(rootVM: RootViewModel(mainContext: dev.viewContext))
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
       
    private func cellView(_ project: ProjectEntity) -> some View{
        ZStack {
            Color.white
            Image(uiImage: project.uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
            LinearGradient(colors: [.black.opacity(0.35), .black.opacity(0.2), .black.opacity(0.1)], startPoint: .bottom, endPoint: .top)
        }
        .hCenter()
        .frame(height: 150)
        .cornerRadius(5)
        .clipped()
        .overlay {
            VStack{
                Button {
                    rootVM.removeProject(project)
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                }
                .hTrailing()
                Spacer()
                Text(project.createAt?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    .foregroundColor(.white)
                    .hLeading()
            }
            .font(.footnote.weight(.medium))
            .padding(10)
        }
    }
    
    
    private func loadPhotosItem(_ newItem: PhotosPickerItem?){
        Task {
            self.showLoader = true
            if let video = try await newItem?.loadTransferable(type: VideoItem.self) {
                selectedVideoURL = video.url
                try await Task.sleep(for: .milliseconds(50))
                self.showLoader = false
                self.showEditor.toggle()
                
            } else {
                print("Failed load video")
                self.showLoader = false
            }
        }
    }
}
