//
//  SplashBuilder.swift
//  What?fle
//
//  Created by 이정환 on 4/10/24.
//

import RIBs

final class SplashComponent: Component<EmptyDependency> {
    let networkService: NetworkServiceDelegate

    init() {
        let networkService = NetworkService()
        Task {
            await networkService.monitorAuthChanges()
        }
        self.networkService = networkService
        super.init(dependency: EmptyComponent())
    }
}

// MARK: - Builder

protocol SplashBuildable: Buildable {
    func build() -> LaunchRouting
}

final class SplashBuilder: Builder<EmptyDependency>, SplashBuildable {

    override init(dependency: EmptyDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let component = SplashComponent()
        let viewController = SplashViewController()
        let interactor = SplashInteractor(
            presenter: viewController,
            networkService: component.networkService
        )
        return SplashRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
