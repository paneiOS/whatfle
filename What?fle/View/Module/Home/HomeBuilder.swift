//
//  HomeBuilder.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import UIKit

protocol HomeDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var loginUseCase: LoginUseCaseProtocol { get }
    var collectionUseCase: CollectionUseCaseProtocol { get }
    var homeNavigationController: UINavigationController { get }
}

final class HomeComponent: Component<HomeDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }

    var navigationController: UINavigationController {
        return dependency.homeNavigationController
    }

    var collectionUseCase: CollectionUseCaseProtocol {
        return dependency.collectionUseCase
    }
}

extension HomeComponent: DetailCollectionDependency {
    var detailCollectionBuilder: DetailCollectionBuildable {
        return DetailCollectionBuilder(dependency: self)
    }
}

extension HomeComponent: LoginDependency {
    var loginBuilder: LoginBuildable {
        return LoginBuilder(dependency: self)
    }

    var loginUseCase: LoginUseCaseProtocol {
        return dependency.loginUseCase
    }
}

// MARK: - Builder

protocol HomeBuildable: Buildable {
    func build(withListener listener: HomeListener) -> HomeRouting
}

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {

    override init(dependency: HomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: HomeListener) -> HomeRouting {
        let component = HomeComponent(dependency: dependency)
        let viewController = HomeViewController()
        let navigationController = component.navigationController
        navigationController.viewControllers = [viewController]
        navigationController.modalPresentationStyle = .overFullScreen
        let interactor = HomeInteractor(
            presenter: viewController,
            collectionUseCase: component.collectionUseCase
        )
        interactor.listener = listener
        return HomeRouter(
            interactor: interactor,
            viewController: viewController,
            navigationController: navigationController,
            component: component
        )
    }
}
