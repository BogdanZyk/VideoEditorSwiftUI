//
//  AudioSheetView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 04.05.2023.
//

import SwiftUI

struct AudioSheetView: View {
    @ObservedObject var videoPlayer: VideoPlayerManager
    @ObservedObject var editorVM: EditorViewModel
    var body: some View {
        VStack{
            if editorVM.currentVideo?.audio != nil{
                Button {
                    videoPlayer.pause()
                    editorVM.removeAudio()
                } label: {
                    Text("Remove")
                }
            }
        }
    }
}

struct AudioSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AudioSheetView(videoPlayer: VideoPlayerManager(), editorVM: EditorViewModel())
    }
}
