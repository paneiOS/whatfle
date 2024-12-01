//
//  MyPageRouter.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import UIKit

import RIBs

protocol MyPageInteractable: Interactable, DetailCollectionListener, DetailLocationListener, MyContentsListener {
    var router: MyPageRouting? { get set }
    var listener: MyPageListener? { get set }
}

protocol MyPageViewControllable: ViewControllable {}

final class MyPageRouter: ViewableRouter<MyPageInteractable, MyPageViewControllable> {
    private let component: MyPageComponent
    let navigationController: UINavigationController

    weak var detailCollectionRouter: DetailCollectionRouting?
    weak var detailLocationRouter: DetailLocationRouting?
    weak var myContentsRouter: MyContentsRouting?

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

    func routeToDetailLocation(model: HomeDataModel.Collection.Place) {
        if self.detailLocationRouter == nil {
            let router = self.component.detailLocationBuilder.build(withListener: self.interactor, model: model)
            router.viewControllable.uiviewController.hidesBottomBarWhenPushed = true
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.detailLocationRouter = router
        }
    }

    func popToDetailLocation() {
        if let router = self.detailLocationRouter {
            self.navigationController.popViewController(animated: true)
            self.detachChild(router)
            self.detailLocationRouter = nil
        }
    }

    func routeToMyLocations() {
        if self.myContentsRouter == nil {
            let router = self.component.myContentsBuilder.build(withListener: self.interactor, initialIndex: 0)
            router.viewControllable.uiviewController.hidesBottomBarWhenPushed = true
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.myContentsRouter = router
        }
    }

    func routeToMyCollections() {
        if self.myContentsRouter == nil {
            let router = self.component.myContentsBuilder.build(withListener: self.interactor, initialIndex: 1)
            router.viewControllable.uiviewController.hidesBottomBarWhenPushed = true
            self.navigationController.setNavigationBarHidden(true, animated: false)
            self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.myContentsRouter = router
        }
    }

    func popToMyContents() {
        if let router = self.myContentsRouter {
            self.navigationController.popViewController(animated: true)
            self.detachChild(router)
            self.myContentsRouter = nil
        }
    }
}
