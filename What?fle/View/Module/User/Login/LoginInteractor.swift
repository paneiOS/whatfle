//
//  LoginInteractor.swift
//  What?fle
//
//  Created by 이정환 on 8/15/24.
//

import AuthenticationServices

import KakaoSDKUser
import Moya
import RIBs
import RxSwift
import RxKakaoSDKUser
import Supabase

protocol LoginRouting: ViewableRouting {
    var navigationController: UINavigationController? { get }
    func pushProfileRIB()
}

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
                    accessToken: response.accessToken,
                    snsType: .APPLE
                )
                return self.networkService.request(WhatfleAPI.snsLogin(model))
                    .map { response in
                        do {
                            return try JSONDecoder().decode(UserInfo.self, from: response.data)
                        } catch {
                            throw RxError.noElements
                        }

                    }
            }
            .subscribe(onSuccess: { [weak self] model in
                guard let self else { return }
                LoadingIndicatorService.shared.hideLoading()
                try? KeychainManager.saveUserInfo(model: model)
                self.router?.pushProfileRIB()
            }, onFailure: { error in
                LoadingIndicatorService.shared.hideLoading()
                print("Login failed with error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext: {[weak self] oauthToken in
                    // TODO: - 카아오 로그인 오스토큰 발급, 이걸 supabase에 전달해야함.
                }, onError: {error in
                    print(error)
                })
                .disposed(by: disposeBag)
        } else {
            // TODO: - 카카오톡 설치 안된 케이스
        }
    }
    
    func closeLogin() {
//        listener?.dismissLoginRIB()
        self.router?.pushProfileRIB()
    }
}
