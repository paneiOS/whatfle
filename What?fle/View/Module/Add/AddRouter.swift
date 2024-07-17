//
//  AddRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import UIKit

protocol AddInteractable: Interactable, RegistLocationListener, AddCollectionListener, RegistCollectionListener {
    var router: AddRouting? { get set }
    var listener: AddListener? { get set }
}

protocol AddViewControllable: ViewControllable {}

final class AddRouter: ViewableRouter<AddInteractable, AddViewControllable> {
    private let component: AddComponent
    let navigationController: UINavigationController

    weak var registLocationRouter: RegistLocationRouting?
    weak var addCollectionRouter: AddCollectionRouting?
    weak var registCollectionRouter: RegistCollectionRouting?
    weak var editRegistCollectionRouter: RegistCollectionRouting?

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: AddInteractable,
        viewController: AddViewControllable,
        navigationController: UINavigationController,
        component: AddComponent
    ) {
        self.component = component
        self.navigationController = navigationController
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension AddRouter: AddRouting {
    func routeToAddCollection(data: EditSelectedCollectionData?) {
        if self.addCollectionRouter == nil {
            let router = self.component.addCollectionBuilder.build(withListener: self.interactor, withData: data)
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.addCollectionRouter = router
        }
    }

    func routeToRegistLocation() {
        if self.registLocationRouter == nil {
            let router = self.component.registLocatiionBuilder.build(withListener: self.interactor)
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.registLocationRouter = router
        }
    }

    func routeToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) {
        if self.registCollectionRouter == nil {
            let router = self.component.registCollectionBuilder.build(withListener: self.interactor, withData: data, tags: tags)
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.registCollectionRouter = router
        }
    }

    func popToAddCollection() {
        if let router = self.addCollectionRouter {
            self.navigationController.popViewController(animated: true)
            self.detachChild(router)
            self.addCollectionRouter = nil
        }
    }

    func popToRegistCollection() {
        if let router = self.registCollectionRouter {
            self.navigationController.popViewController(animated: true)
            self.detachChild(router)
            self.registCollectionRouter = nil
        }
    }

    func popToRegistLocation() {
        if let router = self.registLocationRouter {
            self.navigationController.popViewController(animated: true)
            self.detachChild(router)
            self.registLocationRouter = nil
        }
    }
}
