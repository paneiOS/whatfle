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
    func routeToLogin()
}

protocol SplashPresentable: Presentable {
    var listener: SplashPresentableListener? { get set }
}

protocol SplashListener: AnyObject {}

final class SplashInteractor: PresentableInteractor<SplashPresentable>, SplashInteractable, SplashPresentableListener {

    weak var router: SplashRouting?
    weak var listener: SplashListener?

    override func didBecomeActive() {
        super.didBecomeActive()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.router?.routeToLogin()
        }
    }
}
