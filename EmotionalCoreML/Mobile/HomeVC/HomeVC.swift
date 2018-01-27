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
import TesseractOCR

class HomeVC: UIViewController {
    
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let model = CNNEmotions()
    var request : VNCoreMLRequest?
    var image : UIImage!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image = #imageLiteral(resourceName: "celil.jpeg")
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
    
    fileprivate func ocr(image: UIImage) {
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            print(tesseract.recognizedText)
            resultLabel.text = tesseract.recognizedText
        }
    }
}

//MARK: ImagePicker Delegations
extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            cameraImage.image = pickedImage.scaleImage(640)
            ocr(image: pickedImage.scaleImage(640)!)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIImage extension
extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
