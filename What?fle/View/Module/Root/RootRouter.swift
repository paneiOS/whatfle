//
//  RootRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/23/24.
//

import RIBs
import UIKit

protocol RootInteractable: Interactable, HomeListener, MyPageListener, AddListener, RegistLocationListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    func setTabBarViewController(_ viewControllers: [UINavigationController], animated: Bool)
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable> {
    private let component: RootComponent

    weak var addRouter: AddRouting?
    weak var registLocationRouter: RegistLocationRouting?

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

        let myPageRouter = component.myPageBuilder.build(withListener: interactor)
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
