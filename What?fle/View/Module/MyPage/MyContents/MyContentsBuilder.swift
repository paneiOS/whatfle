//
//  MyContentsBuilder.swift
//  What?fle
//
//  Created by 이정환 on 12/1/24.
//

import UIKit

import RIBs

protocol MyContentsDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var navigationController: UINavigationController { get }
    var collectionUseCase: CollectionUseCaseProtocol { get }
}

final class MyContentsComponent: Component<MyContentsDependency> {
    var navigationController: UINavigationController {
        return dependency.navigationController
    }

    var collectionUseCase: CollectionUseCaseProtocol {
        return dependency.collectionUseCase
    }
}

// MARK: - Builder

protocol MyContentsBuildable: Buildable {
    func build(withListener listener: MyContentsListener, initialIndex: Int) -> MyContentsRouting
}

final class MyContentsBuilder: Builder<MyContentsDependency>, MyContentsBuildable {

    override init(dependency: MyContentsDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MyContentsListener, initialIndex: Int) -> MyContentsRouting {
        let component = MyContentsComponent(dependency: dependency)
        let viewController = MyContentsViewController(initialIndex: initialIndex)
        let navigationController = component.navigationController
        let interactor = MyContentsInteractor(
            presenter: viewController,
            collectionUseCase: component.collectionUseCase
        )
        interactor.listener = listener
        return MyContentsRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
