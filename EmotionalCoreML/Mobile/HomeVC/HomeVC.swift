//
//  HomeVC.swift
//  EmotionalCoreML
//
//  Created by Celil Bozkurt on 25.01.2018.
//  Copyright © 2018 Celil Bozkurt. All rights reserved.
//

import UIKit
import CoreML
import Vision

class HomeVC: UIViewController {
    
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let model = MobileNet()
    var request : VNCoreMLRequest?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerSetup()
        
        guard let visionModel = try? VNCoreMLModel(for: model.model) else {
            fatalError("error")
        }
        
        self.request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            guard let result = request.results as? [VNClassificationObservation],
                let topResult = result.first else {
                    fatalError("celil")
            }
            
            self?.resultLabel.text = "\(Int(topResult.confidence * 100)) + \(topResult.identifier.description) "
            
        }
    }
}

extension HomeVC {
    fileprivate func imagePickerSetup() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
    }
}

//MARK: Buttons
extension HomeVC {
    @IBAction func takePictureButtonClicked(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: analyze methods
extension HomeVC {
    fileprivate func analyze(image : UIImage) {
        guard let request = self.request else {
            return
        }
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        try? handler.perform([request])
        
    }
    
    fileprivate func ml(image: CVPixelBuffer){
        guard let prediction = try? model.prediction(data: image) else {
            return
        }
        resultLabel.text = prediction.classLabel
        print(prediction.classLabel)
        print(prediction.prob)
       
    }
}

//MARK: ImagePicker Delegations
extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            cameraImage.image = pickedImage
            buffer(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: Helpers
extension HomeVC {
    fileprivate func buffer(image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        ml(image: pixelBuffer!)
    }
}
