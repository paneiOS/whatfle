//
//  MyContentsRouter.swift
//  What?fle
//
//  Created by 이정환 on 12/1/24.
//

import UIKit

import RIBs

protocol MyContentsInteractable: Interactable {
    var router: MyContentsRouting? { get set }
    var listener: MyContentsListener? { get set }
}

protocol MyContentsViewControllable: ViewControllable {}

final class MyContentsRouter: ViewableRouter<MyContentsInteractable, MyContentsViewControllable>, MyContentsRouting {
    private let component: MyContentsComponent

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: MyContentsInteractable,
        viewController: MyContentsViewControllable,
        component: MyContentsComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
