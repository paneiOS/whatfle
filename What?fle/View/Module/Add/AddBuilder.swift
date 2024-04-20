//
//  AddBuilder.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import UIKit
import RIBs

protocol AddDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
}

final class AddComponent: Component<AddDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }
}

extension AddComponent: RegistLocationDependency {
    var registLocatiionBuilder: RegistLocationBuildable {
        return RegistLocationBuilder(dependency: self)
    }
}

extension AddComponent: AddCollectionDependency {
    var addCollectionBuilder: AddCollectionBuildable {
        return AddCollectionBuilder(dependency: self)
    }
}

extension AddComponent: RegistCollectionDependency {
    var registCollectionBuilder: RegistCollectionBuildable {
        return RegistCollectionBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol AddBuildable: Buildable {
    func build(withListener listener: AddListener) -> AddRouting
}

final class AddBuilder: Builder<AddDependency>, AddBuildable {

    deinit {
        print("\(self) is being deinit")
    }

    override init(dependency: AddDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: AddListener) -> AddRouting {
        let component = AddComponent(dependency: dependency)
        let viewController = AddViewController()
        let navigationController = UINavigationController(root: viewController)
        navigationController.modalPresentationStyle = .overFullScreen
        let interactor = AddInteractor(presenter: viewController)
        interactor.listener = listener
        return AddRouter(
            interactor: interactor,
            viewController: viewController,
            navigationController: navigationController,
            component: component
        )
    }
}
