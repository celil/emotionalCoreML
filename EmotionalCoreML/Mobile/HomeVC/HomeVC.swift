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
    
    let model = CNNEmotions()
    var request : VNCoreMLRequest?
    var image : UIImage!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image = #imageLiteral(resourceName: "celil.jpeg")
        imagePicker.delegate = self
        
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

//MARK: Buttons
extension HomeVC {
    @IBAction func takePictureButtonClicked(_ sender: UIButton) {
        analyze(image: image)
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
}

//MARK: ImagePicker Delegations
extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
