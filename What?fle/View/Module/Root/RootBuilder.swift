//
//  RootBuilder.swift
//  What?fle
//
//  Created by 이정환 on 2/23/24.
//

import RIBs
import UIKit

// MARK: - Component

protocol RootDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var loginUseCase: LoginUseCaseProtocol { get }
    var locationUseCase: LocationUseCaseProtocol { get }
    var collectionUseCase: CollectionUseCaseProtocol { get }
    var totalSearchUseCase: TotalSearchUseCaseProtocol { get }
}

final class RootComponent: Component<RootDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }

    var loginUseCase: LoginUseCaseProtocol {
        return dependency.loginUseCase
    }

    var locationUseCase: LocationUseCaseProtocol {
        return dependency.locationUseCase
    }

    var collectionUseCase: CollectionUseCaseProtocol {
        return dependency.collectionUseCase
    }

    var totalSearchUseCase: TotalSearchUseCaseProtocol {
        return dependency.totalSearchUseCase
    }

    let homeNavigationController: UINavigationController = .init()
    let mapNavigationController: UINavigationController = .init()
}

extension RootComponent: HomeDependency, AddDependency, MapDependency, RegistLocationDependency {
    var userInfo: UserInfo? {
        return networkService.sessionManager.loadUserInfo()
    }
    var homeBuilder: HomeBuildable {
        return HomeBuilder(dependency: self)
    }

    var addBuilder: AddBuildable {
        return AddBuilder(dependency: self)
    }

    var mapBuilder: MapBuildable {
        return MapBuilder(dependency: self)
    }

    var registLocationBuilder: RegistLocationBuildable {
        return RegistLocationBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let component = RootComponent(dependency: dependency)
        let viewController = RootViewController()
        let interactor = RootInteractor(presenter: viewController)
        return RootRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
