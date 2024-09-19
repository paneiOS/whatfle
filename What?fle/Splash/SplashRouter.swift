//
//  SplashRouter.swift
//  What?fle
//
//  Created by 이정환 on 4/10/24.
//

import RIBs
import UIKit

protocol SplashInteractable: Interactable {
    var router: SplashRouting? { get set }
    var listener: SplashListener? { get set }
}

protocol SplashViewControllable: ViewControllable {}

final class SplashRouter: LaunchRouter<SplashInteractable, SplashViewControllable>, SplashRouting {
    private let component: SplashComponent

    init(
        interactor: SplashInteractable,
        viewController: SplashViewControllable,
        component: SplashComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToRoot(networkService: NetworkServiceDelegate) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.switchToRoot(networkService: component.networkService)
        }
    }
}
