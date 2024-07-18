//
//  ViewControllable.swift
//  What?fle
//
//  Created by 이정환 on 3/8/24.
//

import RIBs
import UIKit

extension ViewControllable {
    var topViewController: UIViewController? {
        return self.uiviewController.topViewController()
    }
    
    func setPresentationStyle(style: UIModalPresentationStyle) {
        self.uiviewController.modalPresentationStyle = style
    }

    func present(_ viewController: ViewControllable, animated: Bool) {
        self.uiviewController.present(viewController.uiviewController, animated: animated)
    }

    func present(_ navigationController: UINavigationController, animated: Bool) {
        self.uiviewController.present(navigationController, animated: animated)
    }
}
