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
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerSetup()
    }
}

//MARK: Setups & Configurations
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

//MARK: Analyze methods
extension HomeVC {
    fileprivate func defineImage(image: CVPixelBuffer){
        guard let prediction = try? model.prediction(data: image) else {
            return
        }
        
        let value = prediction.prob.max{a, b in a.value < b.value}!.value * 100
        resultLabel.text = "\(prediction.classLabel) \(String(format: "%.2f", value))%"
    }
}

//MARK: ImagePicker Delegations
extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            cameraImage.image = pickedImage
            let bufferImage = pickedImage.pixelBuffer(width: 224, height: 224)
            defineImage(image: bufferImage!)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
