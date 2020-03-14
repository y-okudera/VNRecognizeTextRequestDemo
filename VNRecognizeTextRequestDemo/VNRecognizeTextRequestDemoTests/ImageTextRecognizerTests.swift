//
//  ImageTextRecognizerTests.swift
//  VNRecognizeTextRequestDemoTests
//
//  Created by Yuki Okudera on 2020/03/14.
//  Copyright © 2020 Yuki Okudera. All rights reserved.
//

@testable import VNRecognizeTextRequestDemo
import XCTest

final class ImageTextRecognizerTests: XCTestCase {
    
    var imageTextRecognizer: ImageTextRecognizer?
    var analyzeExpectation: XCTestExpectation?

    override func setUp() {
        self.imageTextRecognizer = ImageTextRecognizer { [weak self] results, error in
            guard let textArray = results else {
                return
            }
            
            // クレジットカード番号形式で絞り込む
            let creditNumbers = textArray.filter { $0.isCreditNumber() }
            print("creditNumbers", creditNumbers)
            
            XCTAssertEqual(creditNumbers.first, "0374 1707 2709 2909")
            
            self?.analyzeExpectation?.fulfill()
        }
    }
    
    /// 画像からクレジットカード番号を取得するテスト
    func testAnalyze() {
        
        analyzeExpectation = self.expectation(description: "Image analyze test")
        
        let testImage = #imageLiteral(resourceName: "card_image")
        imageTextRecognizer?.analyze(cgImage: testImage.cgImage)
        
        wait(for: [analyzeExpectation!], timeout: 10.0)
    }
}
