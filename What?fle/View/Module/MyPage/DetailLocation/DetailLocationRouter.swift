//
//  DetailLocationRouter.swift
//  What?fle
//
//  Created by 이정환 on 11/30/24.
//

import RIBs

protocol DetailLocationInteractable: Interactable {
    var router: DetailLocationRouting? { get set }
    var listener: DetailLocationListener? { get set }
}

protocol DetailLocationViewControllable: ViewControllable {}

final class DetailLocationRouter: ViewableRouter<DetailLocationInteractable, DetailLocationViewControllable> {
    private let component: DetailLocationComponent

    deinit {
        print("\(self) is being deinit")
    }
    
    init(
        interactor: DetailLocationInteractable,
        viewController: DetailLocationViewControllable,
        component: DetailLocationComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension DetailLocationRouter: DetailLocationRouting {}
