//
//  HomeRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import UIKit

protocol HomeInteractable: Interactable, DetailCollectionListener, LoginListener, TotalSearchBarListener {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable> {
    private let component: HomeComponent
    let navigationController: UINavigationController

    weak var loginRouter: LoginRouting?
    weak var detailCollectionRouter: DetailCollectionRouting?
    weak var totalSearchBarRouter: TotalSearchBarRouting?

    private var postLoginAction: (() -> Void)?

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
                self.navigationController.setNavigationBarHidden(true, animated: false)
                self.navigationController.pushViewController(router.viewControllable.uiviewController, animated: true)
                self.attachChild(router)
                self.detailCollectionRouter = router
            }
        }
    }

    func popToDetailCollection() {
        if let router = self.detailCollectionRouter {
            self.navigationController.popViewController(animated: true)
            self.detachChild(router)
            self.detailCollectionRouter = nil
        }
    }

    func routeToTotalSearchBar() {
        if self.totalSearchBarRouter == nil {
            let router = self.component.totalSearchBarBuilder.build(withListener: self.interactor)
            if let navigationController = router.navigationController {
                navigationController.modalPresentationStyle = .fullScreen
                self.viewController.present(navigationController, animated: true)
                self.attachChild(router)
                self.totalSearchBarRouter = router
            }
        }
    }

    func dismissTotalSearchBar() {
        if let router = self.totalSearchBarRouter {
            self.viewController.uiviewController.dismiss(animated: true)
            self.detachChild(router)
            self.totalSearchBarRouter = nil
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
