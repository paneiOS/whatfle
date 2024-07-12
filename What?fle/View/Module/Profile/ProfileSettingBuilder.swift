//
//  ProfileSettingBuilder.swift
//  What?fle
//
//  Created by 23 09 on 7/3/24.
//

import RIBs

protocol ProfileSettingDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
    var supabaseService: SupabaseServiceDelegate { get }
}

final class ProfileSettingComponent: Component<ProfileSettingDependency> {
}

// MARK: - Builder

protocol ProfileSettingBuildable: Buildable {
    func build(withListener listener: ProfileSettingListener) -> ProfileSettingRouting
}

final class ProfileSettingBuilder: Builder<ProfileSettingDependency>, ProfileSettingBuildable {

    override init(dependency: ProfileSettingDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ProfileSettingListener) -> ProfileSettingRouting {
        let component = ProfileSettingComponent(dependency: dependency)
        let viewController = ProfileSettingViewController()
        let interactor = ProfileSettingInteractor(presenter: viewController)
        interactor.listener = listener
        return ProfileSettingRouter(interactor: interactor, viewController: viewController)
    }
}
