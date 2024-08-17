//
//  HomeRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import UIKit

protocol HomeInteractable: Interactable, DetailCollectionListener, LoginListener {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable> {
    private let component: HomeComponent
    let navigationController: UINavigationController

    weak var loginRouter: LoginRouting?
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
    func routeToDetailCollection(id: Int) {
        if self.detailCollectionRouter == nil {
            let router = self.component.detailCollectionBuilder.build(withListener: self.interactor, id: id)
            router.viewControllable.uiviewController.hidesBottomBarWhenPushed = true
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.detailCollectionRouter = router
        }
    }

    func popToDetailCollection() {
        if let router = self.detailCollectionRouter {
            self.navigationController.popViewController(animated: true)
            self.detachChild(router)
            self.detailCollectionRouter = nil
        }
    }

    func showLoginRIB() {
        if self.loginRouter == nil {
            let router = self.component.loginBuilder.build(withListener: self.interactor)
            router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
            self.viewController.present(router.viewControllable, animated: true)
            self.attachChild(router)
            self.loginRouter = router
        }
    }

    func dismissLoginRIB() {
        if let router = self.loginRouter {
            self.viewController.uiviewController.dismiss(animated: true)
            self.detachChild(router)
            self.loginRouter = nil
        }
    }
}
