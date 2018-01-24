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
    
    @IBOutlet weak var resultLabel: UILabel!
    let model = CNNEmotions()
    var request : VNCoreMLRequest?
    var image : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image = #imageLiteral(resourceName: "celil.jpeg")
        
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
    @IBAction func analyzeButtonClicked(_ sender: UIButton) {
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
