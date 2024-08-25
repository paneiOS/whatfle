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

    deinit {
        print("\(self) is being deinit")
    }

    override init(
        interactor: AddTagInteractable,
        viewController: AddTagViewControllable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
