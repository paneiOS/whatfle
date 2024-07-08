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
    private weak var currentChild: ViewableRouting?

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
        let router = self.component.addCollectionBuilder.build(withListener: self.interactor, withData: data)
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
        self.attachChild(router)
        self.currentChild = router
    }

    func routeToRegistLocation() {
        if self.currentChild == nil {
            let router = self.component.registLocatiionBuilder.build(withListener: self.interactor)
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.currentChild = router
        }
    }

    func routeToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) {
        let router = self.component.registCollectionBuilder.build(withListener: self.interactor, withData: data, tags: tags)
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
        self.attachChild(router)
    }

    func closeCurrentRIB() {
        if let currentChild {
            self.detachChild(currentChild)
            self.currentChild = nil
        }
    }
}
