//
//  ProfileBuilder.swift
//  What?fle
//
//  Created by JeongHwan Lee on 8/18/24.
//

import UIKit

import RIBs

protocol ProfileDependency: Dependency {
    var loginUseCase: LoginUseCaseProtocol { get }
}

final class ProfileComponent: Component<ProfileDependency> {
    var loginUseCase: LoginUseCaseProtocol {
        return dependency.loginUseCase
    }
}

extension ProfileComponent: CustomAlbumDependency {
    var customAlbumBuilder: CustomAlbumBuildable {
        return CustomAlbumBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol ProfileBuildable: Buildable {
    func build(withListener listener: ProfileListener, isProfileRequired: Bool) -> ProfileRouting
}

final class ProfileBuilder: Builder<ProfileDependency>, ProfileBuildable {

    override init(dependency: ProfileDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ProfileListener, isProfileRequired: Bool) -> ProfileRouting {
        let component = ProfileComponent(dependency: dependency)
        let viewController = ProfileViewController()
        let interactor = ProfileInteractor(
            presenter: viewController,
            loginUseCase: component.loginUseCase,
            isProfileRequired: isProfileRequired
        )
        interactor.listener = listener
        return ProfileRouter(interactor: interactor, viewController: viewController, component: component)
    }
}
