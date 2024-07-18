//
//  RootInteractor.swift
//  What?fle
//
//  Created by 이정환 on 2/23/24.
//

import RIBs
import RxSwift

protocol RootRouting: ViewableRouting {
    func routeToAddTab()
    func routeToRegistLocation()
    func dismissRegistLocation()
    func dismissAddTab()
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
}

protocol RootListener: AnyObject {}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener, AddListener {
    weak var router: RootRouting?
    weak var listener: RootListener?

    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func didSelectAddTab() {
        router?.routeToAddTab()
    }

    func closeAddRIB() {
        router?.dismissAddTab()
    }

    func showRegistLocation() {
        router?.routeToRegistLocation()
    }

    func closeRegistLocation() {
        self.router?.dismissRegistLocation()
    }

    func completeRegistLocation() {
        self.router?.dismissRegistLocation()
    }
}
