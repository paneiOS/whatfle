//
//  UIViewController+.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import UIKit

extension UIViewController {
    func topViewController() -> UIViewController? {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topViewController()
        }

        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topViewController()
        }

        if let tabBarController = self as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController.topViewController()
            }
        }
        return self
    }
    
    func setupDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

