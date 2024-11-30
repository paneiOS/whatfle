//
//  MyPageRouter.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import UIKit

import RIBs

protocol MyPageInteractable: Interactable, DetailCollectionListener {
    var router: MyPageRouting? { get set }
    var listener: MyPageListener? { get set }
}

protocol MyPageViewControllable: ViewControllable {}

final class MyPageRouter: ViewableRouter<MyPageInteractable, MyPageViewControllable> {
    private let component: MyPageComponent
    let navigationController: UINavigationController
    
    weak var detailCollectionRouter: DetailCollectionRouting?

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: MyPageInteractable,
        viewController: MyPageViewControllable,
        navigationController: UINavigationController,
        component: MyPageComponent
    ) {
        self.component = component
        self.navigationController = navigationController
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension MyPageRouter: MyPageRouting {
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
}
