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
    }
    
}

