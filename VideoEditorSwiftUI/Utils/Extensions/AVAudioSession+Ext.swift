//
//  AVAudioSession+Ext.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 04.05.2023.
//

import AVFoundation

extension AVAudioSession{
    
    
    func playAndRecord(){
        print("Configuring playAndRecord session")
        do {
            try self.setCategory(.playAndRecord, mode: .default)
            try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            print("AVAudio Session out options: ", self.currentRoute)
          print("Successfully configured audio session.")
        } catch (let error) {
          print("Error while configuring audio session: \(error)")
        }
    }
    
    func configureRecordAudioSessionCategory() {
      print("Configuring record session")
      do {
          try self.setCategory(.record, mode: .default)
          try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
          print("AVAudio Session out options: ", self.currentRoute)
        print("Successfully configured audio session.")
      } catch (let error) {
        print("Error while configuring audio session: \(error)")
      }
    }
    
    func configurePlaybackSession(){
        print("Configuring playback session")
        do {
            try self.setCategory(.playback, mode: .default)
            try self.overrideOutputAudioPort(.none)
            try self.setActive(true)
            print("Current audio route: ", self.currentRoute.outputs)
        } catch let error as NSError {
            print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
        }
    }
}
