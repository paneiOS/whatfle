//
//  DetailCollectionBuilder.swift
//  What?fle
//
//  Created by 이정환 on 8/1/24.
//

import RIBs

protocol DetailCollectionDependency: Dependency {}

final class DetailCollectionComponent: Component<DetailCollectionDependency> {}

// MARK: - Builder

protocol DetailCollectionBuildable: Buildable {
    func build(withListener listener: DetailCollectionListener) -> DetailCollectionRouting
}

final class DetailCollectionBuilder: Builder<DetailCollectionDependency>, DetailCollectionBuildable {

    override init(dependency: DetailCollectionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DetailCollectionListener) -> DetailCollectionRouting {
        let component = DetailCollectionComponent(dependency: dependency)
        let viewController = DetailCollectionViewController()
        let interactor = DetailCollectionInteractor(presenter: viewController)
        interactor.listener = listener
        return DetailCollectionRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
