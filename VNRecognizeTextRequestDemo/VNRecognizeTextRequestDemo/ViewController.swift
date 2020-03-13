//
//  ViewController.swift
//  VNRecognizeTextRequestDemo
//
//  Created by Yuki Okudera on 2020/03/13.
//  Copyright © 2020 Yuki Okudera. All rights reserved.
//

import UIKit
import Vision

final class ViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.image = #imageLiteral(resourceName: "sample")
        }
    }
    
    private let loadingText = "解析中..."
    
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .fast
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        return request
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showIndicatorAlert(message: loadingText)
        processImage()
    }
}

extension ViewController {
    
    private func processImage() {
        textView.text = ""
        
        guard let cgImage = imageView.image?.cgImage else {
            return
        }
        
        let requests = [textDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("perform error", error)
            }
        }
    }
    
    private func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            print("error", error)
            return
        }
        
        guard let results = request?.results, results.count > 0 else {
            print("No text")
            return
        }
        
        var textSet = ""
        
        let candidates = 1
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(candidates) {
                    textSet.append(text.string + "\n")
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.hideIndicatorAlert()
            self?.textView.text = textSet
        }
    }
}
