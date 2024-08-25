//
//  ProfileRouter.swift
//  What?fle
//
//  Created by JeongHwan Lee on 8/18/24.
//

import RIBs

protocol ProfileInteractable: Interactable, CustomAlbumListener {
    var router: ProfileRouting? { get set }
    var listener: ProfileListener? { get set }
}

protocol ProfileViewControllable: ViewControllable {}

final class ProfileRouter: ViewableRouter<ProfileInteractable, ProfileViewControllable>, ProfileRouting {
    private let component: ProfileComponent

    private weak var customAlbumRouter: CustomAlbumRouting?

    init(
        interactor: ProfileInteractable,
        viewController: ProfileViewControllable,
        component: ProfileComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func showCustomAlbum() {
        if self.customAlbumRouter == nil {
            let router = self.component.customAlbumBuilder.buildSingleSelect(withListener: self.interactor)
            router.viewControllable.setPresentationStyle(style: .overFullScreen)
            self.viewController.present(router.viewControllable, animated: true)
            self.attachChild(router)
            self.customAlbumRouter = router
        }
    }

    func closeCustomAlbum() {
        if let customAlbumRouter {
            customAlbumRouter.viewControllable.uiviewController.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                self.detachChild(customAlbumRouter)
                self.customAlbumRouter = nil
            }
        }
    }
}
