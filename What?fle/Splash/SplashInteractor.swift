//
//  SplashInteractor.swift
//  What?fle
//
//  Created by 이정환 on 4/10/24.
//

import Foundation
import RIBs
import RxSwift

protocol SplashRouting: ViewableRouting {
    func routeToRoot(networkService: NetworkServiceDelegate)
}

protocol SplashPresentable: Presentable {
    var listener: SplashPresentableListener? { get set }
}

protocol SplashListener: AnyObject {}

final class SplashInteractor: PresentableInteractor<SplashPresentable>, SplashInteractable, SplashPresentableListener {

    weak var router: SplashRouting?
    weak var listener: SplashListener?

    private let networkService: NetworkServiceDelegate

    init(presenter: SplashPresentable, networkService: NetworkServiceDelegate) {
        self.networkService = networkService
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            router?.routeToRoot(networkService: self.networkService)
        }
    }
}
