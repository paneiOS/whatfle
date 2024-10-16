//
//  AddRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import UIKit

import RIBs

protocol AddInteractable: Interactable, RegistLocationListener, AddCollectionListener, RegistCollectionListener, LoginListener {
    var router: AddRouting? { get set }
    var listener: AddListener? { get set }
}

protocol AddViewControllable: ViewControllable {}

final class AddRouter: ViewableRouter<AddInteractable, AddViewControllable> {
    private let component: AddComponent
    let navigationController: UINavigationController

    weak var loginRouter: LoginRouting?
    weak var registLocationRouter: RegistLocationRouting?
    weak var addCollectionRouter: AddCollectionRouting?
    weak var registCollectionRouter: RegistCollectionRouting?
    weak var editRegistCollectionRouter: RegistCollectionRouting?

    private var postLoginAction: (() -> Void)?

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
    private func setPostLoginAction(_ action: @escaping () -> Void) {
        postLoginAction = action
    }

    private func executePostLoginAction() {
        postLoginAction?()
        postLoginAction = nil
    }

    func proceedToNextScreenAfterLogin() {
        dismissLoginRIB { [weak self] in
            guard let self else { return }
            self.executePostLoginAction()
        }
    }

    func routeToAddCollection(data: EditSelectedCollectionData?) {
        if !component.networkService.isLogin {
            self.setPostLoginAction { [weak self] in
                guard let self else { return }
                self.routeToAddCollection(data: data)
            }
            self.showLoginRIB()
        } else {
            if self.addCollectionRouter == nil {
                let router = self.component.addCollectionBuilder.build(withListener: self.interactor, withData: data)
                self.navigationController.setNavigationBarHidden(true, animated: false)
                self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
                self.attachChild(router)
                self.addCollectionRouter = router
            }
        }
    }

    func routeToRegistLocation() {
        if self.registLocationRouter == nil {
            guard let id = self.component.dependency.networkService.sessionManager.loadUserInfo()?.id else {
                return
            }
            let router = self.component.registLocationBuilder.build(withListener: self.interactor, accountID: id)
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

    func showRegistLocation() {
        if !component.networkService.isLogin {
            self.setPostLoginAction { [weak self] in
                guard let self else { return }
                self.showRegistLocation()
            }
            self.showLoginRIB()
        } else {
            if self.registLocationRouter == nil {
                guard let id = self.component.dependency.networkService.sessionManager.loadUserInfo()?.id else {
                    return
                }
                let router = self.component.registLocationBuilder.build(withListener: self.interactor, accountID: id)
                self.navigationController.setNavigationBarHidden(true, animated: false)
                self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
                self.attachChild(router)
                self.registLocationRouter = router
            }
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

    func showLoginRIB() {
        if self.loginRouter == nil {
            let router = self.component.loginBuilder.build(withListener: self.interactor)
            if let navigationController = router.navigationController {
                navigationController.modalPresentationStyle = .fullScreen
                self.viewController.present(navigationController, animated: true)
                self.attachChild(router)
                self.loginRouter = router
            }
        }
    }

    func dismissLoginRIB(completion: (() -> Void)?) {
        if let router = self.loginRouter {
            self.viewController.uiviewController.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                completion?()
                self.detachChild(router)
                self.loginRouter = nil
                self.postLoginAction = nil
            }
        }
    }
}
