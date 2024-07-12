//
//  ProfileSettingRouter.swift
//  What?fle
//
//  Created by 23 09 on 7/3/24.
//

import RIBs

protocol ProfileSettingInteractable: Interactable {
    var router: ProfileSettingRouting? { get set }
    var listener: ProfileSettingListener? { get set }
}

protocol ProfileSettingViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileSettingRouter: ViewableRouter<ProfileSettingInteractable, ProfileSettingViewControllable>, ProfileSettingRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: ProfileSettingInteractable, viewController: ProfileSettingViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
