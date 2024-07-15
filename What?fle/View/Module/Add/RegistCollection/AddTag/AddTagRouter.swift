//
//  AddTagRouter.swift
//  What?fle
//
//  Created by 이정환 on 7/8/24.
//

import RIBs

protocol AddTagInteractable: Interactable {
    var router: AddTagRouting? { get set }
    var listener: AddTagListener? { get set }
}

protocol AddTagViewControllable: ViewControllable {}

final class AddTagRouter: ViewableRouter<AddTagInteractable, AddTagViewControllable>, AddTagRouting {
    private let component: AddTagComponent

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: AddTagInteractable,
        viewController: AddTagViewControllable,
        component: AddTagComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
