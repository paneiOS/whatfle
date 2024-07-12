//
//  ProfileSettingInteractor.swift
//  What?fle
//
//  Created by 23 09 on 7/3/24.
//

import RIBs
import RxSwift

protocol ProfileSettingRouting: ViewableRouting {
}

protocol ProfileSettingPresentable: Presentable {
    var listener: ProfileSettingPresentableListener? { get set }
}

protocol ProfileSettingListener: AnyObject {
}

final class ProfileSettingInteractor: PresentableInteractor<ProfileSettingPresentable>, ProfileSettingInteractable, ProfileSettingPresentableListener {

    weak var router: ProfileSettingRouting?
    weak var listener: ProfileSettingListener?

    override init(presenter: ProfileSettingPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
