//
//  RegistCollectionBuilder.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import RIBs

protocol RegistCollectionDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
}

final class RegistCollectionComponent: Component<RegistCollectionDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }
}

extension RegistCollectionComponent: AddCollectionDependency {
    var addCollectionBuilder: AddCollectionBuildable {
        return AddCollectionBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol RegistCollectionBuildable: Buildable {
    func build(withListener listener: RegistCollectionListener, withData data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) -> RegistCollectionRouting
}

final class RegistCollectionBuilder: Builder<RegistCollectionDependency>, RegistCollectionBuildable {

    deinit {
        print("\(self) is being deinit")
    }

    override init(dependency: RegistCollectionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: RegistCollectionListener, withData data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) -> RegistCollectionRouting {
        let component = RegistCollectionComponent(dependency: dependency)
        let viewController = RegistCollectionViewController()
        let interactor = RegistCollectionInteractor(
            presenter: viewController,
            networkService: component.networkService,
            data: data,
            tags: tags
        )
        interactor.listener = listener
        return RegistCollectionRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
