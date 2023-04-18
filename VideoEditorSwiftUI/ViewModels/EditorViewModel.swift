//
//  EditorViewModel.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import Foundation
import AVKit
import SwiftUI

final class EditorViewModel: ObservableObject{
    
    
    var asset: AVAsset?
    
    
    func setAsset(_ url: URL){
        asset = AVAsset(url: url)
    }
    
    
    
}



