//
//  MyPageBuilder.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import UIKit

import RIBs

protocol MyPageDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var myPageNavigationController: UINavigationController { get }
    var collectionUseCase: CollectionUseCaseProtocol { get }
}

final class MyPageComponent: Component<MyPageDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }

    var navigationController: UINavigationController {
        return dependency.myPageNavigationController
    }

    var collectionUseCase: CollectionUseCaseProtocol {
        return dependency.collectionUseCase
    }
}

extension MyPageComponent: DetailCollectionDependency {
    var detailCollectionBuilder: DetailCollectionBuildable {
        return DetailCollectionBuilder(dependency: self)
    }
}

extension MyPageComponent: DetailLocationDependency {
    var detailLocationBuilder: DetailLocationBuildable {
        return DetailLocationBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol MyPageBuildable: Buildable {
    func build(withListener listener: MyPageListener) -> MyPageRouting
}

final class MyPageBuilder: Builder<MyPageDependency>, MyPageBuildable {

    override init(dependency: MyPageDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MyPageListener) -> MyPageRouting {
        let component = MyPageComponent(dependency: dependency)
        let viewController = MyPageViewController()
        let navigationController = component.navigationController
        navigationController.viewControllers = [viewController]
        navigationController.modalPresentationStyle = .overFullScreen
        let interactor = MyPageInteractor(
            presenter: viewController,
            collectionUseCase: component.collectionUseCase
        )
        interactor.listener = listener
        return MyPageRouter(
            interactor: interactor,
            viewController: viewController,
            navigationController: navigationController,
            component: component
        )
    }
}
