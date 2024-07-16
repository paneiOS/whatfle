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

protocol CustomAlbumViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CustomAlbumRouter: ViewableRouter<CustomAlbumInteractable, CustomAlbumViewControllable>, CustomAlbumRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: CustomAlbumInteractable, viewController: CustomAlbumViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
