//
//  AppComponent.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs

final class AppComponent: Component<EmptyComponent>, RootDependency {
    let networkService: NetworkServiceDelegate

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

    var totalSearchUseCase: TotalSearchUseCaseProtocol {
        let totalSearchRepository = TotalSearchRepository(networkService: networkService)
        return TotalSearchUseCase(totalSearchRepostory: totalSearchRepository)
    }

    init(networkService: NetworkServiceDelegate) {
        self.networkService = networkService
        super.init(dependency: EmptyComponent())
    }

    var builder: RootBuildable {
        return RootBuilder(dependency: self)
    }
}
