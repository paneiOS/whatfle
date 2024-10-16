//
//  RegistLocationBuilder.swift
//  What?fle
//
//  Created by 이정환 on 3/5/24.
//

import RIBs

protocol RegistLocationDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var locationUseCase: LocationUseCaseProtocol { get }
}

final class RegistLocationComponent: Component<RegistLocationDependency> {
    var locationUseCase: LocationUseCaseProtocol {
        return dependency.locationUseCase
    }
}

extension RegistLocationComponent: SelectLocationDependency, CustomAlbumDependency {
    var selectLocationBuilder: SelectLocationBuildable {
        return SelectLocationBuilder(dependency: self)
    }

    var customAlbumBuilder: CustomAlbumBuildable {
        return CustomAlbumBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol RegistLocationBuildable: Buildable {
    func build(withListener listener: RegistLocationListener, accountID: Int) -> RegistLocationRouting
}

final class RegistLocationBuilder: Builder<RegistLocationDependency>, RegistLocationBuildable {

    deinit {
        print("\(self) is being deinit")
    }

    override init(dependency: RegistLocationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: RegistLocationListener, accountID: Int) -> RegistLocationRouting {
        let component = RegistLocationComponent(dependency: dependency)
        let viewController = RegistLocationViewController()
        let interactor = RegistLocationInteractor(
            presenter: viewController,
            locationUseCase: component.locationUseCase,
            accountID: accountID
        )
        interactor.listener = listener
        viewController.listener = interactor
        return RegistLocationRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
