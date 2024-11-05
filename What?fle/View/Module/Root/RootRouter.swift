//
//  RootRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/23/24.
//

import RIBs
import UIKit

protocol RootInteractable: Interactable, HomeListener, MyPageListener, AddListener, RegistLocationListener, LoginListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    func setTabBarViewController(_ viewControllers: [UINavigationController], animated: Bool)
    func selectMyPageTab()
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable> {
    private let component: RootComponent

    weak var addRouter: AddRouting?
    weak var myPageRouter: MyPageRouting?
    weak var loginRouter: LoginRouting?
    weak var registLocationRouter: RegistLocationRouting?

    private var postLoginAction: (() -> Void)?

    init(
        interactor: RootInteractable,
        viewController: RootViewControllable,
        component: RootComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override func didLoad() {
        self.attachChildRIBs()
    }

    func attachChildRIBs() {
        let homeRouter = component.homeBuilder.build(withListener: interactor)
        let homeNavigation = component.homeNavigationController
        homeNavigation.setNavigationBarHidden(true, animated: false)
        homeNavigation.tabBarItem = tabBarItem(type: .home)
        attachChild(homeRouter)

        let dummyNavigation = UINavigationController()
        dummyNavigation.tabBarItem = tabBarItem(type: .add)

        let myPageRouter = component.myPageBuilder.build(withListener: self.interactor)
        let myPageNavigation = component.myPageNavigationController
        myPageNavigation.setNavigationBarHidden(true, animated: false)
        myPageNavigation.tabBarItem = tabBarItem(type: .myPage)
        attachChild(myPageRouter)

        let viewControllables = [homeNavigation, dummyNavigation, myPageNavigation]
        viewController.setTabBarViewController(viewControllables, animated: false)
    }
}

extension RootRouter {
    private func tabBarItem(type: ItemType) -> UITabBarItem {
        return .init(title: type.tatile, image: type.defaultImage, selectedImage: type.selectedImage)
    }
}

extension RootRouter: RootRouting {
    func routeToAddTab() {
        if self.addRouter == nil {
            let router = self.component.addBuilder.build(withListener: self.interactor)
            router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
            self.viewController.present(router.navigationController, animated: false)
            self.attachChild(router)
            self.addRouter = router
        }
    }

    func dismissAddTab() {
        if let router = self.addRouter {
            self.viewController.uiviewController.dismiss(animated: true)
            self.detachChild(router)
            self.addRouter = nil
        }
    }

    func dismissRegistLocation() {
        if let router = self.registLocationRouter {
            self.viewController.uiviewController.dismiss(animated: true)
            self.detachChild(router)
            self.registLocationRouter = nil
        }
    }

    private func setPostLoginAction(_ action: @escaping () -> Void) {
        postLoginAction = action
    }

    private func executePostLoginAction() {
        postLoginAction?()
        postLoginAction = nil
    }

    func proceedToNextScreenAfterLogin() {
        self.dismissLoginRIB { [weak self] in
            guard let self else { return }
            self.executePostLoginAction()
        }
    }

    func routeToMyPage() {
        if component.networkService.isLogin {
            self.viewController.selectMyPageTab()
        } else {
            self.setPostLoginAction { [weak self] in
                guard let self else { return }
                self.routeToMyPage()
            }
            self.showLoginRIB()
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

// MARK: - enum ItemType
extension RootRouter {
    private enum ItemType: CaseIterable {
        case home, add, myPage

        var tatile: String {
            switch self {
            case .home:
                return "홈"
            case .add:
                return "추가"
            case .myPage:
                return "마이페이지"
            }
        }

        var defaultImage: UIImage {
            switch self {
            case .home:
                return .homeLine
            case .add:
                return .addLine
            case .myPage:
                return .mypageLine
            }
        }

        var selectedImage: UIImage {
            switch self {
            case .home:
                return .homeFilled
            case .add:
                return .addFilled
            case .myPage:
                return .mypageFilled
            }
        }
    }
}
