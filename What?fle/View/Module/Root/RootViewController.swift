//
//  RootViewController.swift
//  What?fle
//
//  Created by 이정환 on 2/23/24.
//

import RIBs
import RxSwift
import UIKit

protocol RootPresentableListener: AnyObject {
    func didSelectAddTab()
    func didSelectMyPageTab()
}

final class RootViewController: UITabBarController, RootPresentable {

    weak var listener: RootPresentableListener?
    private var animationInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.setTabBar()
        self.setUI()
    }
}

extension RootViewController {
    private func setTabBar() {
        self.tabBar.tintColor = .GrayScale.g400
    }

    private func setUI() {
        view.backgroundColor = .white
    }
}

extension RootViewController: RootViewControllable {
    func setTabBarViewController(_ viewControllers: [UINavigationController], animated: Bool) {
        let viewControllers = viewControllers.map { $0 }
        self.setViewControllers(viewControllers, animated: animated)
    }

    func selectMyPageTab() {
        selectedIndex = 2
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        let index = self.viewControllers?.firstIndex(of: viewController)
        switch index {
        case 1:
            listener?.didSelectAddTab()
            return false
        case 2:
            listener?.didSelectMyPageTab()
            return SessionManager.shared.isLogin
        default:
            return true
        }
    }
}
