//
//  SelectLocationBuilder.swift
//  What?fle
//
//  Created by 이정환 on 2/25/24.
//

import RIBs

protocol SelectLocationDependency: Dependency {
    var locationUseCase: LocationUseCaseProtocol { get }
}

final class SelectLocationComponent: Component<SelectLocationDependency> {
    var locationUseCase: LocationUseCaseProtocol {
        return dependency.locationUseCase
    }
}

// MARK: - Builder

protocol SelectLocationBuildable: Buildable {
    func build(withListener listener: SelectLocationListener) -> SelectLocationRouting
}

final class SelectLocationBuilder: Builder<SelectLocationDependency>, SelectLocationBuildable {

    deinit {
        print("\(self) is being deinit")
    }

    override init(dependency: SelectLocationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SelectLocationListener) -> SelectLocationRouting {
        let component = SelectLocationComponent(dependency: dependency)
        let viewController = SelectLocationViewController()
        let interactor = SelectLocationInteractor(
            presenter: viewController,
            locationUseCase: component.locationUseCase
        )
        interactor.listener = listener
        viewController.listener = interactor
        return SelectLocationRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
