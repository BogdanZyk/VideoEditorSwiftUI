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
    
    @Published var currentTime: Double = .zero
    @Published var selectedItem: PhotosPickerItem?
    @Published var loadState: LoadState = .unknown
    @Published private(set) var player = AVPlayer()
    @Published private(set) var isPlaying: Bool = false
    private var cancellable = Set<AnyCancellable>()
    private var timeObserver: Any?
    private var currentDurationRange: ClosedRange<Double>?
    
    
    deinit {
        removeTimeObserver()
    }
    
    init(){
        onSubsUrl()
    }
    
    
    var scrubState: PlayerScrubState = .reset {
        didSet {
            switch scrubState {
            case .scrubEnded(let seekTime):
                pause()
                player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600))
            default : break
            }
        }
    }
    
    func action(_ video: Video){
        self.currentDurationRange = video.rangeDuration
        if isPlaying{
            pause()
        }else{
            play(video.rate)
        }
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
                    self.startStatusSubscriptions()
                    print("AVPlayer set url:", url.absoluteString)
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
                    self.startTimer()
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
    

    private func play(_ rate: Float?){
        
        if let currentDurationRange{
            if currentTime >= currentDurationRange.upperBound{
                player.seek(to: CMTime(seconds: currentDurationRange.lowerBound, preferredTimescale: 600))
            }else{
                player.seek(to: CMTime(seconds: player.currentTime().seconds, preferredTimescale: 600))
            }
        }
        player.play()
        
        if let rate{
            player.rate = rate
        }
        
        if let currentDurationRange, player.currentItem?.duration.seconds ?? 0 >= currentDurationRange.upperBound{
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                self.playerDidFinishPlaying()
            }
        }
    }
    
    private func startTimer() {
        
        let interval = CMTimeMake(value: 1, timescale: 10)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.isPlaying{
                let time = time.seconds
                
                if let currentDurationRange = self.currentDurationRange, time >= currentDurationRange.upperBound{
                    self.pause()
                }

                switch self.scrubState {
                case .reset:
                    self.currentTime = time
                case .scrubEnded:
                    self.scrubState = .reset
                case .scrubStarted:
                    break
                }
            }
        }
    }
    
    
    private func playerDidFinishPlaying() {
        self.player.seek(to: .zero)
    }
    
    private func removeTimeObserver(){
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
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


extension VideoPlayerManager{
    
    
    func setFilter(_ filter: CIFilter?){
        guard let filter else {return}
        self.pause()
        DispatchQueue.global(qos: .userInteractive).async {
            let composition = self.player.currentItem?.asset.setFilter(filter)
            self.player.currentItem?.videoComposition = composition
        }
    }
    
    func removeFilter(){
        pause()
        player.currentItem?.videoComposition = nil
    }
}

enum LoadState: Identifiable, Equatable {
    case unknown, loading, loaded(URL), failed
    
    var id: Int{
        switch self {
        case .unknown: return 0
        case .loading: return 1
        case .loaded: return 2
        case .failed: return 3
        }
    }
}


enum PlayerScrubState{
    case reset
    case scrubStarted
    case scrubEnded(Double)
}


extension AVAsset{
    
    func setFilter(_ filter: CIFilter) -> AVVideoComposition{
        let composition = AVVideoComposition(asset: self, applyingCIFiltersWithHandler: { request in
            filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
            
            guard let output = filter.outputImage else {return}
            
            request.finish(with: output, context: nil)
        })
        
        return composition
    }
    

}
