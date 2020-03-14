//
//  ViewController.swift
//  VNRecognizeTextRequestDemo
//
//  Created by Yuki Okudera on 2020/03/13.
//  Copyright © 2020 Yuki Okudera. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.image = #imageLiteral(resourceName: "no_image")
        }
    }
    
    private let loadingText = "Analyzing..."
    
    private var imagePicker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VNRecognizeTextRequestがサポートしている言語をコンソールに出力する
        ImageTextRecognizer.checkSupportedRecognitionLanguages()
    }
    
    private lazy var imageTextRecognizer: ImageTextRecognizer = {
        
        // ハンドラに文字列認識後の処理を定義
        let imageTextRecognizer = ImageTextRecognizer { [weak self] results, error in
            
            guard let `self` = self else {
                return
            }
            guard let textArray = results else {
                if let imageTextRecognizerError = error {
                    print(imageTextRecognizerError)
                }
                return
            }
            
            // クレジットカード番号形式で絞り込む
            let creditNumbers = textArray.filter { $0.isCreditNumber() }
            print("creditNumbers", creditNumbers)
            
            self.textField.text = creditNumbers.first
            self.hideIndicatorAlert()
        }
        return imageTextRecognizer
    }()
    
    @IBAction private func tappedCameraButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Select", message: "Please take a credit card.", preferredStyle: .actionSheet)
        actionSheet.addAction(
            .init(title: "Camera", style: .default) { [weak self] _ in
                self?.openCamera()
            }
        )
        actionSheet.addAction(
            .init(title: "PhotoLibrary", style: .default) { [weak self] _ in
                self?.openPhotoLibrary()
            }
        )
        actionSheet.addAction(
            .init(title: "Cancel", style: .cancel)
        )
        self.present(actionSheet, animated: true)
    }
}

extension ViewController {
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Not available camera.")
            return
        }
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    private func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Not available photoLibrary.")
            return
        }
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(#function)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image is nil.")
            return
        }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.imageView.image = image
            // インジケータを表示して、画像のテキスト解析する
            self.showIndicatorAlert(message: self.loadingText)
            self.imageTextRecognizer.analyze(cgImage: image.cgImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(#function)
        picker.dismiss(animated: true)
    }
}

extension ViewController: UINavigationControllerDelegate { }
