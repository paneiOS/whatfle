//
//  TotalSearchBarRouter.swift
//  What?fle
//
//  Created by 이정환 on 10/1/24.
//

import UIKit

import RIBs

protocol TotalSearchBarInteractable: Interactable, DetailCollectionListener, LoginListener {
    var router: TotalSearchBarRouting? { get set }
    var listener: TotalSearchBarListener? { get set }
}

protocol TotalSearchBarViewControllable: ViewControllable {}

final class TotalSearchBarRouter: ViewableRouter<TotalSearchBarInteractable, TotalSearchBarViewControllable> {
    private let component: TotalSearchBarComponent
    var navigationController: UINavigationController?

    weak var loginRouter: LoginRouting?
    weak var detailCollectionRouter: DetailCollectionRouting?

    private var postLoginAction: (() -> Void)?

    init(
        interactor: TotalSearchBarInteractable,
        viewController: TotalSearchBarViewControllable,
        navigationController: UINavigationController,
        component: TotalSearchBarComponent
    ) {
        self.component = component
        self.navigationController = navigationController
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension TotalSearchBarRouter: TotalSearchBarRouting {
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

    func routeToDetailCollection(id: Int) {
        if !component.networkService.isLogin {
            self.setPostLoginAction { [weak self] in
                guard let self else { return }
                self.routeToDetailCollection(id: id)
            }
            self.showLoginRIB()
        } else {
            if self.detailCollectionRouter == nil {
                let router = self.component.detailCollectionBuilder.build(withListener: self.interactor, id: id)
                router.viewControllable.uiviewController.hidesBottomBarWhenPushed = true
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
                self.attachChild(router)
                self.detailCollectionRouter = router
            }
        }
    }

    func popToDetailCollection() {
        if let router = self.detailCollectionRouter {
            self.navigationController?.popViewController(animated: true)
            self.detachChild(router)
            self.detailCollectionRouter = nil
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
