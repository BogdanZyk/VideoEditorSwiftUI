//
//  VideoPlayerManager.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import Foundation
import Combine
import AVKit
import PhotosUI
import SwiftUI


final class VideoPlayerManager: ObservableObject{
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var loadState: LoadState = .unknown
    @Published private(set) var player = AVPlayer()
    @Published private(set) var isPlaying: Bool = false
    private var cancellable = Set<AnyCancellable>()
    
    
    
    init(){
        onSubsUrl()
        startStatusSubscriptions()
    }
    
    
    private func onSubsUrl(){
        $loadState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            
            .sink {[weak self] returnLoadState in
                guard let self = self else {return}
                
                switch returnLoadState {
                case .loaded(let url):
                    self.pause()
                    self.player = AVPlayer(url: url)
                    print(url.absoluteString)
                case .failed, .loading, .unknown:
                    break
                }
            }
            .store(in: &cancellable)
    }
    
    
    private func startStatusSubscriptions(){
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                guard let self = self else {return}
                switch status {
                case .playing:
                    self.isPlaying = true
                case .paused:
                    self.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellable)
    }
    
    
    func pause(){
        if isPlaying{
            player.pause()
        }
    }
    
}

extension VideoPlayerManager{
    
    @MainActor
    func loadVideoItem(_ selectedItem: PhotosPickerItem?) async{
        do {
            loadState = .loading

            if let video = try await selectedItem?.loadTransferable(type: VideoItem.self) {
                loadState = .loaded(video.url)
            } else {
                loadState = .failed
            }
        } catch {
            loadState = .failed
        }
    }
}

enum LoadState {
    case unknown, loading, loaded(URL), failed
}
