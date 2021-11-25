//
//  ViewController.swift
//  Bookmark
//
//  Created by James Dunn on 10/19/21.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //    First, make your view controller conform to both UINavigationControllerDelegate, and UIImagePickerControllerDelegate.
    
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var bookmarkedQuote: UITextView!
    let imagePickerVC = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.sizeToFit()
    }
    
    private func confirmPermissionToAccessCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            return
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    return
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
    
    @IBAction private func takePhoto() {
        confirmPermissionToAccessCamera()
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }
        imagePickerVC.sourceType = .camera
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage, let cgImage = image.cgImage else {
            print("No image found")
            return
        }
        // print out the image size as a test
        print(image.size)
        
        // Create Vision request to read text from image
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
            do {
                try imageRequestHandler.perform([request])
//                let results = request.results
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        // Process the recognized strings.
        print("Recognized Strings: \na\(recognizedStrings)")
        DispatchQueue.main.async {
            self.bookmarkedQuote.text = recognizedStrings.joined(separator: " ")
        }
//        processResults(recognizedStrings)
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

