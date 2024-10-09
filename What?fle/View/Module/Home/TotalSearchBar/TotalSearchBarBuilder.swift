//
//  TotalSearchBarBuilder.swift
//  What?fle
//
//  Created by 이정환 on 10/1/24.
//

import UIKit

import RIBs

protocol TotalSearchBarDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var loginUseCase: LoginUseCaseProtocol { get }
    var totalSearchUseCase: TotalSearchUseCaseProtocol { get }
}

final class TotalSearchBarComponent: Component<TotalSearchBarDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }

    var totalSearchUseCase: TotalSearchUseCaseProtocol {
        return dependency.totalSearchUseCase
    }
}

extension TotalSearchBarComponent: DetailCollectionDependency {
    var detailCollectionBuilder: DetailCollectionBuildable {
        return DetailCollectionBuilder(dependency: self)
    }
}

extension TotalSearchBarComponent: LoginDependency {
    var loginBuilder: LoginBuildable {
        return LoginBuilder(dependency: self)
    }

    var loginUseCase: LoginUseCaseProtocol {
        return dependency.loginUseCase
    }
}

// MARK: - Builder

protocol TotalSearchBarBuildable: Buildable {
    func build(withListener listener: TotalSearchBarListener) -> TotalSearchBarRouting
}

final class TotalSearchBarBuilder: Builder<TotalSearchBarDependency>, TotalSearchBarBuildable {

    override init(dependency: TotalSearchBarDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TotalSearchBarListener) -> TotalSearchBarRouting {
        let component = TotalSearchBarComponent(dependency: dependency)
        let viewController = TotalSearchBarViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        let interactor = TotalSearchBarInteractor(
            presenter: viewController,
            totalSearchUseCase: component.totalSearchUseCase
        )
        interactor.listener = listener
        return TotalSearchBarRouter(
            interactor: interactor,
            viewController: viewController,
            navigationController: navigationController,
            component: component
        )
    }
}
