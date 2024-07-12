//
//  LoginBuilder.swift
//  What?fle
//
//  Created by 23 09 on 7/2/24.
//

import RIBs
import UIKit

protocol LoginDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var supabaseService: SupabaseServiceDelegate { get }
}

final class LoginComponent: Component<EmptyComponent>, LoginDependency, ProfileSettingDependency {
    init() {
        super.init(dependency: EmptyComponent())
    }

    var builder: LoginBuildable {
        return LoginBuilder(dependency: self)
    }

    var profileSettingBuilder: ProfileSettingBuildable {
        return ProfileSettingBuilder(dependency: self)
    }

    var networkService: NetworkServiceDelegate {
        return NetworkService()
    }

    var supabaseService: SupabaseServiceDelegate {
        return SupabaseService()
    }

}

// MARK: - Builder

protocol LoginBuildable: Buildable {
    func build() -> LaunchRouting
}

final class LoginBuilder: Builder<LoginDependency>, LoginBuildable {

    override init(dependency: LoginDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let component = LoginComponent()
        let viewController = LoginViewController()
        let navigationController = UINavigationController(root: viewController)
        navigationController.modalPresentationStyle = .overFullScreen
        let interactor = LoginInteractor(presenter: viewController, networkService: component.networkService, supabaseService: component.supabaseService)
        let window: UIWindow? = UIApplication.shared.keyWindow
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        interactor.activate()
        return LoginRouter(
            interactor: interactor,
            viewController: viewController,
            navigationController: navigationController,
            component: component
        )
    }
}
