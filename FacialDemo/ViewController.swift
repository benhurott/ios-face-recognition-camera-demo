//
//  ViewController.swift
//  FacialDemo
//
//  Created by Ben-Hur Santos Ott on 09/01/2018.
//  Copyright © 2018 Emerald. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var faceBoundsView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faceBoundsView.layer.cornerRadius = faceBoundsView.bounds.height * 0.5
        faceBoundsView.layer.masksToBounds = true
        
        let captureDevice = self.getDevice(position: .front)
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer!)
        
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        captureSession?.addOutput(capturePhotoOutput)
        
        captureSession?.startRunning()
        
        self.watchPhoto()
    }
    
    func setFaceBoundsViewBorderColor(_ color: UIColor) {
        self.faceBoundsView.layer.borderWidth = 1
        self.faceBoundsView.layer.borderColor = color.cgColor
    }
    
    func showMessage(_ message: String) {
        self.messageLabel.text = message
    }

    func getDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(
            deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
            mediaType: AVMediaTypeVideo,
            position: AVCaptureDevicePosition.unspecified) {
            
            for device in deviceDescoverySession.devices {
                if device.position == position {
                    return device
                }
            }
        }
        
        return nil
    }
    
    func detect() {
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        let personciImage = CIImage.init(cgImage: imageView.image!.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions as? [String : AnyObject])
        
        if let face = faces?.first as? CIFaceFeature {
            print("found bounds are x:\(face.bounds.origin.x) | y: \(face.bounds.origin.y) | w: \(face.bounds.size.width) | h: \(face.bounds.size.height)")
            
            if face.bounds.size.width < 1300 {
                self.setFaceBoundsViewBorderColor(.red)
                self.showMessage("Aproxime o rosto")
            }
            else if face.bounds.size.width > 1800 {
                self.setFaceBoundsViewBorderColor(.red)
                self.showMessage("Afaste o rosto")
            }
            else {
                self.setFaceBoundsViewBorderColor(.green)
                self.showMessage("Ok")
            }
            return
        }
        
        self.showMessage("Assim não =(")
        self.setFaceBoundsViewBorderColor(.red)
    }
    
    func watchPhoto() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.capturePhoto()
            self.watchPhoto()
        }
    }
    
    func capturePhoto() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    @IBAction func takePhoto(_ sender: Any) {
        self.capturePhoto()
    }
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                 previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        
        // get captured image
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            self.imageView.image = image
            
            self.detect()
        }
    }
}

