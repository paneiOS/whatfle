//
//  DetailCollectionRouter.swift
//  What?fle
//
//  Created by 이정환 on 8/1/24.
//

import RIBs
import UIKit

protocol DetailCollectionInteractable: Interactable {
    var router: DetailCollectionRouting? { get set }
    var listener: DetailCollectionListener? { get set }
}

protocol DetailCollectionViewControllable: ViewControllable {}

final class DetailCollectionRouter: ViewableRouter<DetailCollectionInteractable, DetailCollectionViewControllable> {
    private let component: DetailCollectionComponent

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: DetailCollectionInteractable,
        viewController: DetailCollectionViewControllable,
        component: DetailCollectionComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension DetailCollectionRouter: DetailCollectionRouting {}
