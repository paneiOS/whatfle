//
//  CustomAlbumInteractor.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import RIBs
import RxSwift

protocol CustomAlbumRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol CustomAlbumPresentable: Presentable {
    var listener: CustomAlbumPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol CustomAlbumListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class CustomAlbumInteractor: PresentableInteractor<CustomAlbumPresentable>, CustomAlbumInteractable, CustomAlbumPresentableListener {

    weak var router: CustomAlbumRouting?
    weak var listener: CustomAlbumListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: CustomAlbumPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
