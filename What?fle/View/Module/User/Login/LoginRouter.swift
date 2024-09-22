//
//  LoginRouter.swift
//  What?fle
//
//  Created by 이정환 on 8/15/24.
//

import UIKit

import RIBs

protocol LoginInteractable: Interactable, ProfileListener {
    var router: LoginRouting? { get set }
    var listener: LoginListener? { get set }
}

protocol LoginViewControllable: ViewControllable {}

final class LoginRouter: ViewableRouter<LoginInteractable, LoginViewControllable>, LoginRouting {
    private let component: LoginComponent
    var navigationController: UINavigationController?

    weak var profileRouter: ProfileRouting?

    deinit {
        print("\(self) is being deinit")
    }

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

    func pushProfileRIB(isProfileRequired: Bool) {
        if self.profileRouter == nil {
            let router = self.component.profileBuilder.build(withListener: self.interactor, isProfileRequired: isProfileRequired)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.profileRouter = router
        }
    }

    func popToProfileView() {
        if let profileRouter {
            self.navigationController?.popViewController(animated: true)
            self.detachChild(profileRouter)
            self.profileRouter = nil
        }
    }
}
