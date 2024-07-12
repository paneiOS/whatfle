//
//  LoginRouter.swift
//  What?fle
//
//  Created by 23 09 on 7/2/24.
//

import RIBs
import UIKit

protocol LoginInteractable: Interactable, ProfileSettingListener {
    var router: LoginRouting? { get set }
    var listener: LoginListener? { get set }
}

protocol LoginViewControllable: ViewControllable {
}

final class LoginRouter: LaunchRouter<LoginInteractable, LoginViewControllable> {
    private let component: LoginComponent
    private weak var currentChild: ViewableRouting?
    private let navigationController: UINavigationController

    init(
        interactor: LoginInteractable,
        viewController: LoginViewControllable,
        navigationController: UINavigationController,
        component: LoginComponent
    ) {
        self.component = component
        self.navigationController = navigationController
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

}

extension LoginRouter: LoginRouting {
    func routeToProfileSetting() {
        let router = self.component.profileSettingBuilder.build(withListener: self.interactor)
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
        self.attachChild(router)
        self.currentChild = router
    }
}
