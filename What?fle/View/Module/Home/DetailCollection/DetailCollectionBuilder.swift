//
//  DetailCollectionBuilder.swift
//  What?fle
//
//  Created by 이정환 on 8/1/24.
//

import RIBs

protocol DetailCollectionDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
}

final class DetailCollectionComponent: Component<DetailCollectionDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }
}

// MARK: - Builder

protocol DetailCollectionBuildable: Buildable {
    func build(withListener listener: DetailCollectionListener, id: Int) -> DetailCollectionRouting
}

final class DetailCollectionBuilder: Builder<DetailCollectionDependency>, DetailCollectionBuildable {

    override init(dependency: DetailCollectionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DetailCollectionListener, id: Int) -> DetailCollectionRouting {
        let component = DetailCollectionComponent(dependency: dependency)
        let viewController = DetailCollectionViewController()
        let interactor = DetailCollectionInteractor(
            presenter: viewController,
            networkService: dependency.networkService,
            collectionID: id
        )
        interactor.listener = listener
        return DetailCollectionRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
