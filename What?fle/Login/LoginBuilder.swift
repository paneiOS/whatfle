//
//  LoginBuilder.swift
//  What?fle
//
//  Created by 23 09 on 7/2/24.
//

import RIBs

protocol LoginDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class LoginComponent: Component<EmptyComponent>, LoginDependency {
    init() {
        super.init(dependency: EmptyComponent())
    }

    var builder: LoginBuildable {
        return LoginBuilder(dependency: self)
    }

    var networkService: NetworkServiceDelegate {
        return NetworkService()
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
        let interactor = LoginInteractor(presenter: viewController)
        return LoginRouter(interactor: interactor, viewController: viewController, component: component)
    }
}
