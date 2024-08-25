//
//  AppComponent.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs

class AppComponent: Component<EmptyComponent>, RootDependency {
    let networkService: NetworkServiceDelegate = NetworkService()

    var loginUseCase: LoginUseCaseProtocol {
        let loginRepository = LoginRepository(networkService: networkService)
        return LoginUseCase(loginRepository: loginRepository)
    }

    var locationUseCase: LocationUseCaseProtocol {
        let locationRepository = LocationRepository(networkService: networkService)
        return LocationUseCase(locationRepository: locationRepository)
    }

    var collectionUseCase: CollectionUseCaseProtocol {
        let collectionRepository = CollectionRepository(networkService: networkService)
        return CollectionUseCase(collectionRepository: collectionRepository)
    }

    init() {
        super.init(dependency: EmptyComponent())
    }

    var builder: RootBuildable {
        return RootBuilder(dependency: self)
    }
}
