//
//  LoginBuilder.swift
//  What?fle
//
//  Created by 이정환 on 8/15/24.
//

import UIKit

import RIBs

protocol LoginDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
}

final class LoginComponent: Component<LoginDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }
}

extension LoginComponent: ProfileDependency {
    var profileBuilder: ProfileBuildable {
        return ProfileBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol LoginBuildable: Buildable {
    func build(withListener listener: LoginListener) -> LoginRouting
}

final class LoginBuilder: Builder<LoginDependency>, LoginBuildable {

    override init(dependency: LoginDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: LoginListener) -> LoginRouting {
        let component = LoginComponent(dependency: dependency)
        let viewController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
            
        
        let interactor = LoginInteractor(
            presenter: viewController,
            networkService: dependency.networkService
        )
        interactor.listener = listener
        return LoginRouter(
            interactor: interactor,
            viewController: viewController,
            navigationController: navigationController,
            component: component
        )
    }
}
