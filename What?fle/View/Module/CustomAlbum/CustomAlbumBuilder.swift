//
//  CustomAlbumBuilder.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import RIBs

protocol CustomAlbumDependency: Dependency {}

final class CustomAlbumComponent: Component<CustomAlbumDependency> {}

// MARK: - Builder

protocol CustomAlbumBuildable: Buildable {
    func buildSingleSelect(withListener listener: CustomAlbumListener) -> CustomAlbumRouting
    func buildMultiSelect(withListener listener: CustomAlbumListener) -> CustomAlbumRouting
}

final class CustomAlbumBuilder: Builder<CustomAlbumDependency>, CustomAlbumBuildable {

    deinit {
        print("\(self) is being deinit")
    }

    override init(dependency: CustomAlbumDependency) {
        super.init(dependency: dependency)
    }

    func buildSingleSelect(withListener listener: CustomAlbumListener) -> CustomAlbumRouting {
        let viewController = CustomAlbumViewController(isSingleSelect: true)
        let interactor = CustomAlbumInteractor(presenter: viewController)
        interactor.listener = listener
        return CustomAlbumRouter(
            interactor: interactor,
            viewController: viewController
        )
    }

    func buildMultiSelect(withListener listener: CustomAlbumListener) -> CustomAlbumRouting {
        let viewController = CustomAlbumViewController(isSingleSelect: false)
        let interactor = CustomAlbumInteractor(presenter: viewController)
        interactor.listener = listener
        return CustomAlbumRouter(
            interactor: interactor,
            viewController: viewController
        )
    }
}
