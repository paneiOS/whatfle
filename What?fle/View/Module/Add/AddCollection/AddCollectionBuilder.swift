//
//  AddCollectionBuilder.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import RIBs

protocol AddCollectionDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
}

final class AddCollectionComponent: Component<AddCollectionDependency> {}

extension AddCollectionComponent: AddCollectionDependency {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }

    var selectLocationBuilder: AddCollectionBuildable {
        return AddCollectionBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol AddCollectionBuildable: Buildable {
    func build(withListener listener: AddCollectionListener) -> AddCollectionRouting
}

final class AddCollectionBuilder: Builder<AddCollectionDependency>, AddCollectionBuildable {
    
    deinit {
        print("\(self) is being deinit")
    }

    override init(dependency: AddCollectionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: AddCollectionListener) -> AddCollectionRouting {
        let component = AddCollectionComponent(dependency: dependency)
        let viewController = AddCollectionViewController()
        let interactor = AddCollectionInteractor(presenter: viewController, networkService: component.networkService)
        interactor.listener = listener
        return AddCollectionRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
