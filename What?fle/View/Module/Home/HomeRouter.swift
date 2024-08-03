//
//  HomeRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import UIKit

protocol HomeInteractable: Interactable, DetailCollectionListener {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable> {
    private let component: HomeComponent
    let navigationController: UINavigationController

    weak var detailCollectionRouter: DetailCollectionRouting?

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: HomeInteractable,
        viewController: HomeViewControllable,
        navigationController: UINavigationController,
        component: HomeComponent
    ) {
        self.component = component
        self.navigationController = navigationController
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension HomeRouter: HomeRouting {
    func routeToDetailCollection() {
        if self.detailCollectionRouter == nil {
            let router = self.component.detailCollectionBuilder.build(withListener: self.interactor)
            router.viewControllable.uiviewController.hidesBottomBarWhenPushed = true
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.detailCollectionRouter = router
        }
    }
}
