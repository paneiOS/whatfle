//
//  DetailLocationBuilder.swift
//  What?fle
//
//  Created by 이정환 on 11/30/24.
//

import RIBs

protocol DetailLocationDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
}

final class DetailLocationComponent: Component<DetailLocationDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }
}

// MARK: - Builder

protocol DetailLocationBuildable: Buildable {
    func build(withListener listener: DetailLocationListener, model: HomeDataModel.Collection.Place) -> DetailLocationRouting
}

final class DetailLocationBuilder: Builder<DetailLocationDependency>, DetailLocationBuildable {

    override init(dependency: DetailLocationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DetailLocationListener, model: HomeDataModel.Collection.Place) -> DetailLocationRouting {
        let component = DetailLocationComponent(dependency: dependency)
        let viewController = DetailLocationViewController()
        let interactor = DetailLocationInteractor(
            presenter: viewController,
            networkService: dependency.networkService,
            detailLocationModel: model
        )
        interactor.listener = listener
        return DetailLocationRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
