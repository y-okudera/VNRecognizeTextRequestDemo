//
//  UIViewController+IndicatorAlert.swift
//  VNRecognizeTextRequestDemo
//
//  Created by Yuki Okudera on 2020/03/13.
//  Copyright © 2020 Yuki Okudera. All rights reserved.
//

import UIKit

extension UIViewController {

    func showIndicatorAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.center = .init(x: 25, y: 30)
        alert.view.addSubview(indicator)
        indicator.startAnimating()
        present(alert, animated: true)
    }

    func hideIndicatorAlert(completion: (() -> Void)? = nil) {
        if let alert = getTopViewController() as? UIAlertController {
            alert.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
    }

    private func getTopViewController() -> UIViewController? {
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }
        
        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
}
