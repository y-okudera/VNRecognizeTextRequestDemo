//
//  ImageTextRecognizer.swift
//  VNRecognizeTextRequestDemo
//
//  Created by Yuki Okudera on 2020/03/14.
//  Copyright © 2020 Yuki Okudera. All rights reserved.
//

import CoreGraphics
import Vision

enum ImageTextRecognizerError: Error {
    case imageNotFound
    case recognizeTextRequestIsNil
    case requestError(Error)
    case performError(Error)
    case noText
}

typealias ImageTextRecognizeHandler = ([String]?, ImageTextRecognizerError?) -> Void

final class ImageTextRecognizer: NSObject {
    
    var recognizeTextRequest: VNRecognizeTextRequest?
    var completionHandler: ImageTextRecognizeHandler
    
    init(completionHandler: @escaping ImageTextRecognizeHandler) {
        
        self.completionHandler = completionHandler
        super.init()
        
        recognizeTextRequest = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        recognizeTextRequest?.recognitionLevel = .fast
        recognizeTextRequest?.recognitionLanguages = ["en_US"]
        recognizeTextRequest?.usesLanguageCorrection = true
    }
    
    func analyze(cgImage: CGImage?) {
        
        guard let cgImage = cgImage else {
            self.completionHandler(nil, .imageNotFound)
            return
        }
        guard let recognizeTextRequest = self.recognizeTextRequest else {
            self.completionHandler(nil, .recognizeTextRequestIsNil)
            return
        }
        let requests = [recognizeTextRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("VNImageRequestHandler perform error", error)
                self.completionHandler(nil, .performError(error))
            }
        }
    }
    
    private func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            print("error", error)
            DispatchQueue.main.async { [weak self] in
                self?.completionHandler(nil, .requestError(error))
            }
            return
        }
        
        guard let results = request?.results, results.count > 0 else {
            print("No text")
            DispatchQueue.main.async { [weak self] in
                self?.completionHandler(nil, .noText)
            }
            return
        }
        
        var textArray = [String]()
        
        // 認識された文字列の上位何件の候補を要求するか
        let candidates = 1
        
        for result in results {
            guard let observation = result as? VNRecognizedTextObservation else {
                continue
            }
            // 認識された候補の数だけループ(candidatesの値に依存)
            for text in observation.topCandidates(candidates) {
                print("Recognized text", text.string)
                textArray.append(text.string)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler(textArray, nil)
        }
    }
}

extension ImageTextRecognizer {
    
    /// サポートしている言語をチェックする
    static func checkSupportedRecognitionLanguages() {
        do {
            let supportedLanguagesForFast = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .fast, revision: VNRecognizeTextRequestRevision1)
            print("supportedRecognitionLanguages fast:", supportedLanguagesForFast)
            let supportedLanguagesForAccurate = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision1)
            print("supportedRecognitionLanguages accurate:", supportedLanguagesForAccurate)
            
        } catch let error {
            print("supportedRecognitionLanguages error", error)
        }
    }
}
