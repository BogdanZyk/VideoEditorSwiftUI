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
    @Published private(set) var videoPlayer = AVPlayer()
    @Published private(set) var audioPlayer = AVPlayer()
    @Published private(set) var isPlaying: Bool = false
    private var isSetAudio: Bool = false
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
                seek(seekTime, player: videoPlayer)
                if isSetAudio{
                    seek(seekTime, player: audioPlayer)
                }
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
    
    func setAudio(_ url: URL?){
        guard let url else {
            isSetAudio = false
            return
        }
        audioPlayer = .init(url: url)
        isSetAudio = true
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
                    self.videoPlayer = AVPlayer(url: url)
                    self.startStatusSubscriptions()
                    print("AVPlayer set url:", url.absoluteString)
                case .failed, .loading, .unknown:
                    break
                }
            }
            .store(in: &cancellable)
    }
    
    
    private func startStatusSubscriptions(){
        videoPlayer.publisher(for: \.timeControlStatus)
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
            videoPlayer.pause()
            if isSetAudio{
                audioPlayer.pause()
            }
        }
    }
    
    func setVolume(_ isVideo: Bool, value: Float){
        pause()
        if isVideo{
            videoPlayer.volume = value
        }else{
            audioPlayer.volume = value
        }
    }

    private func play(_ rate: Float?){
        
        AVAudioSession.sharedInstance().configurePlaybackSession()
        
        if let currentDurationRange{
            if currentTime >= currentDurationRange.upperBound{
                seek(currentDurationRange.lowerBound, player: videoPlayer)
                if isSetAudio{
                    seek(currentDurationRange.lowerBound, player: audioPlayer)
                }
            }else{
                seek(videoPlayer.currentTime().seconds, player: videoPlayer)
                if isSetAudio{
                    seek(audioPlayer.currentTime().seconds, player: audioPlayer)
                }
            }
        }
        videoPlayer.play()
        if isSetAudio{
            audioPlayer.play()
        }
        
        if let rate{
            videoPlayer.rate = rate
            if isSetAudio{
                audioPlayer.play()
            }
        }
        
        if let currentDurationRange, videoPlayer.currentItem?.duration.seconds ?? 0 >= currentDurationRange.upperBound{
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { _ in
                self.playerDidFinishPlaying()
            }
        }
    }
    
    private func seek(_ seconds: Double, player: AVPlayer){
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }
    
    private func startTimer() {
        
        let interval = CMTimeMake(value: 1, timescale: 10)
        timeObserver = videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
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
        self.videoPlayer.seek(to: .zero)
    }
    
    private func removeTimeObserver(){
        if let timeObserver = timeObserver {
            videoPlayer.removeTimeObserver(timeObserver)
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
    

    func setFilters(mainFilter: CIFilter?, colorCorrection: ColorCorrection?){
       
        let filters = Helpers.createFilters(mainFilter: mainFilter, colorCorrection)
        
        if filters.isEmpty{
            return
        }
        self.pause()
        DispatchQueue.global(qos: .userInteractive).async {
            let composition = self.videoPlayer.currentItem?.asset.setFilters(filters)
            self.videoPlayer.currentItem?.videoComposition = composition
        }
    }
        
    func removeFilter(){
        pause()
        videoPlayer.currentItem?.videoComposition = nil
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
    
    func setFilters(_ filters: [CIFilter]) -> AVVideoComposition{
        let composition = AVVideoComposition(asset: self, applyingCIFiltersWithHandler: { request in
            
            let source = request.sourceImage
            var output = source
            
            filters.forEach { filter in
                filter.setValue(output, forKey: kCIInputImageKey)
                if let image = filter.outputImage{
                    output = image
                }
            }
            
            request.finish(with: output, context: nil)
        })
        
        return composition
    }

}
