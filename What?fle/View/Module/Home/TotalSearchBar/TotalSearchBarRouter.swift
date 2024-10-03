//
//  TotalSearchBarRouter.swift
//  What?fle
//
//  Created by 이정환 on 10/1/24.
//

import RIBs

protocol TotalSearchBarInteractable: Interactable {
    var router: TotalSearchBarRouting? { get set }
    var listener: TotalSearchBarListener? { get set }
}

protocol TotalSearchBarViewControllable: ViewControllable {}

final class TotalSearchBarRouter: ViewableRouter<TotalSearchBarInteractable, TotalSearchBarViewControllable>, TotalSearchBarRouting {
    private let component: TotalSearchBarComponent

    init(
        interactor: TotalSearchBarInteractable,
        viewController: TotalSearchBarViewControllable,
        component: TotalSearchBarComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
