//
//  LoginRouter.swift
//  What?fle
//
//  Created by 이정환 on 8/15/24.
//

import RIBs

protocol LoginInteractable: Interactable {
    var router: LoginRouting? { get set }
    var listener: LoginListener? { get set }
}

protocol LoginViewControllable: ViewControllable {}

final class LoginRouter: ViewableRouter<LoginInteractable, LoginViewControllable>, LoginRouting {
    private let component: LoginComponent

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: LoginInteractable,
        viewController: LoginViewControllable,
        component: LoginComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
