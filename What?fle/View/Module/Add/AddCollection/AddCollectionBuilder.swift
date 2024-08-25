//
//  AddCollectionBuilder.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import Foundation
import RIBs

protocol AddCollectionDependency: Dependency {
    var locationUseCase: LocationUseCaseProtocol { get }
    var collectionUseCase: CollectionUseCaseProtocol { get }
}

final class AddCollectionComponent: Component<AddCollectionDependency> {}

extension AddCollectionComponent: AddCollectionDependency {
    var locationUseCase: LocationUseCaseProtocol {
        return dependency.locationUseCase
    }

    var collectionUseCase: CollectionUseCaseProtocol {
        return dependency.collectionUseCase
    }
}

extension AddCollectionComponent: RegistCollectionDependency {
    var registCollectionBuilder: RegistCollectionBuildable {
        return RegistCollectionBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol AddCollectionBuildable: Buildable {
    func build(withListener listener: AddCollectionListener, withData data: [(IndexPath, PlaceRegistration)]?) -> AddCollectionRouting
}

final class AddCollectionBuilder: Builder<AddCollectionDependency>, AddCollectionBuildable {

    deinit {
        print("\(self) is being deinit")
    }

    override init(dependency: AddCollectionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: AddCollectionListener, withData data: [(IndexPath, PlaceRegistration)]?) -> AddCollectionRouting {
        let component = AddCollectionComponent(dependency: dependency)
        let viewController = AddCollectionViewController()
        let interactor = AddCollectionInteractor(
            presenter: viewController,
            locationUseCase: component.locationUseCase,
            collectionUseCase: component.collectionUseCase,
            data: data
        )
        interactor.listener = listener
        return AddCollectionRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
