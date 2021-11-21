//
//  ViewController.swift
//  Bookmark
//
//  Created by James Dunn on 10/19/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var bookmarkedQuote: UITextView!
    private var captureSession: AVCaptureSession!
    private var previewView: PreviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.sizeToFit()
    }
    
    @IBAction private func takePhoto() {
        confirmPermissionToAccessCamera()
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }
        print("Button tapped")
        captureSession.beginConfiguration()
        // Setup camera input
        guard
            let photoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back),
            let photoDeviceInput = try? AVCaptureDeviceInput(device: photoDevice),
            captureSession.canAddInput(photoDeviceInput)
        else { return }
        captureSession.addInput(photoDeviceInput)
        
        // Setup camera output
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
    }
    
    private func confirmPermissionToAccessCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.setupCaptureSession()
            
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession()
                    }
                }
            
            case .denied: // The user has previously denied access.
                return

            case .restricted: // The user can't grant access due to restrictions.
                return
        @unknown default:
            fatalError("A new camera authorization status has been added without being accounted for in switch statement")
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        previewView = PreviewView()
        previewView.videoPreviewLayer.session = captureSession
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

