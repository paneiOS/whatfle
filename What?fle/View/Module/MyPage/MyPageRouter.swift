//
//  MyPageRouter.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import UIKit

import RIBs

protocol MyPageInteractable: Interactable {
    var router: MyPageRouting? { get set }
    var listener: MyPageListener? { get set }
}

protocol MyPageViewControllable: ViewControllable {}

final class MyPageRouter: ViewableRouter<MyPageInteractable, MyPageViewControllable>, MyPageRouting {
    private let component: MyPageComponent
    let navigationController: UINavigationController

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: MyPageInteractable,
        viewController: MyPageViewControllable,
        navigationController: UINavigationController,
        component: MyPageComponent
    ) {
        self.component = component
        self.navigationController = navigationController
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
