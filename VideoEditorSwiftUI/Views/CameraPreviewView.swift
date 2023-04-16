//
//  CameraPreviewView.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 14.04.2023.
//

import SwiftUI
import AVKit

class CameraPreviewView: UIView{
    
    private var captureSession: AVCaptureSession
    
    
    init(captureSession: AVCaptureSession) {
        self.captureSession = captureSession
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass{
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer{
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if nil != self.superview{
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspectFill
        }else{
            self.videoPreviewLayer.session = nil
            self.videoPreviewLayer.removeFromSuperlayer()
        }
    }
}


struct CameraPreviewHolder: UIViewRepresentable{
    
    typealias UIViewType = CameraPreviewView
    
    var captureSession: AVCaptureSession
    
    
    func makeUIView(context: Context) -> CameraPreviewView {
        CameraPreviewView(captureSession: captureSession)
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        
    }
}

