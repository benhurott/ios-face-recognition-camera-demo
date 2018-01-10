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
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
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

    @IBAction func onTakePhotoPressed(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        self.captureSession?.stopRunning()
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
        }
    }
}

