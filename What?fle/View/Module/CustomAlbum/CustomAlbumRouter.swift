//
//  CustomAlbumRouter.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import RIBs

protocol CustomAlbumInteractable: Interactable {
    var router: CustomAlbumRouting? { get set }
    var listener: CustomAlbumListener? { get set }
}

protocol CustomAlbumViewControllable: ViewControllable {}

final class CustomAlbumRouter: ViewableRouter<CustomAlbumInteractable, CustomAlbumViewControllable>, CustomAlbumRouting {
    private let component: CustomAlbumComponent

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: CustomAlbumInteractable,
        viewController: CustomAlbumViewControllable,
        component: CustomAlbumComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
