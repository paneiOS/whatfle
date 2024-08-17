//
//  LoginInteractor.swift
//  What?fle
//
//  Created by 이정환 on 8/15/24.
//

import AuthenticationServices

import Moya
import RIBs
import RxSwift

protocol LoginRouting: ViewableRouting {}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

protocol LoginListener: AnyObject {
    func dismissLoginRIB()
}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable, LoginPresentableListener {

    weak var router: LoginRouting?
    weak var listener: LoginListener?

    private let networkService: NetworkServiceDelegate
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(presenter: LoginPresentable, networkService: NetworkServiceDelegate) {
        self.networkService = networkService
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension LoginInteractor {
    func appleLogin(idToken: String) {
        networkService.signInWithIDToken(provider: .apple, idToken: idToken)
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] response -> Single<UserInfo> in
                guard let self = self,
                let email = response.user.email,
                !LoadingIndicatorService.shared.isLoading() else {
                    return Single.error(RxError.noElements)
                }
                LoadingIndicatorService.shared.showLoading()

                let model: LoginRequestModel = .init(
                    email: email,
                    uuid: response.user.id.uuidString.lowercased(),
                    accessToken: response.accessToken
                )
                return self.networkService.request(WhatfleAPI.appleLogin(model))
                    .map { response in
                        do {
                            return try JSONDecoder().decode(UserInfo.self, from: response.data)
                        } catch {
                            throw RxError.noElements
                        }

                    }
            }
            .subscribe(onSuccess: { model in
                LoadingIndicatorService.shared.hideLoading()
                try? KeychainManager.saveUserInfo(model: model)
                // TODO: - 프로필 설정 화면
            }, onFailure: { error in
                LoadingIndicatorService.shared.hideLoading()
                print("Login failed with error: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func closeLogin() {
        listener?.dismissLoginRIB()
    }
}
