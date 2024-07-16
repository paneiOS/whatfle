//
//  CustomAlbumBuilder.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import RIBs

protocol CustomAlbumDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class CustomAlbumComponent: Component<CustomAlbumDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol CustomAlbumBuildable: Buildable {
    func build(withListener listener: CustomAlbumListener) -> CustomAlbumRouting
}

final class CustomAlbumBuilder: Builder<CustomAlbumDependency>, CustomAlbumBuildable {

    override init(dependency: CustomAlbumDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: CustomAlbumListener) -> CustomAlbumRouting {
        let component = CustomAlbumComponent(dependency: dependency)
        let viewController = CustomAlbumViewController()
        let interactor = CustomAlbumInteractor(presenter: viewController)
        interactor.listener = listener
        return CustomAlbumRouter(interactor: interactor, viewController: viewController)
    }
}
