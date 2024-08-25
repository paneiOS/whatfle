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

    deinit {
        print("\(self) is being deinit")
    }

    override init(interactor: CustomAlbumInteractable, viewController: CustomAlbumViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
