//
//  LoginInteractor.swift
//  What?fle
//
//  Created by 23 09 on 7/2/24.
//
import AuthenticationServices
import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import RIBs
import RxSwift
import RxKakaoSDKCommon
import RxKakaoSDKUser

protocol LoginRouting: ViewableRouting {
    func closeLogin()
}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

protocol LoginListener: AnyObject {
    func dismissLogin()
}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable, LoginPresentableListener {
    weak var router: LoginRouting?
    weak var listener: LoginListener?

    private let networkService: NetworkServiceDelegate
    private let supabaseService: SupabaseServiceDelegate
    private let appleLoginHelper: AppleLoginHelper
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(presenter: LoginPresentable, networkService: NetworkServiceDelegate, supabaseService: SupabaseServiceDelegate) {
        self.networkService = networkService
        self.supabaseService = supabaseService
        self.appleLoginHelper = AppleLoginHelper()
        super.init(presenter: presenter)
        presenter.listener = self
        appleLoginHelper.delegate = self
    }

    func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext: { [weak self] oauthToken in
                    guard let self = self else { return }
                    self.getKaKaoUserInfo(oauthToken: oauthToken)
                }, onError: { error in
                    print("loginWithKakaoTalk() error: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        }
    }

    private func getKaKaoUserInfo(oauthToken: OAuthToken) {
        UserApi.shared.rx.me()
            .flatMap { [weak self] user -> Single<LoginModel> in
                guard let self = self else { return Single.error(RxError.unknown) }
                let email = user.kakaoAccount?.email ?? ""
                return self.signinWhatfle(loginInfo: WhatfleAPI.kakaoLogin(email, "", oauthToken))
            }
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.router?.closeLogin()
            }, onFailure: { _ in
                // TODO: 카카오 로그인 실패 처리
            })
            .disposed(by: disposeBag)
    }

    func loginWithApple() {
        appleLoginHelper.startAppleLogin()
    }

    func signinWhatfle(loginInfo: WhatfleAPI) -> Single<LoginModel> {
        networkService.request(loginInfo)
        .map { response -> LoginModel in
            return try JSONDecoder().decode(LoginModel.self, from: response.data)
        }
    }
}
// MARK: 애플 로그인 델리게이트
extension LoginInteractor: AppleLoginHelperDelegate {
    func didCompleteWithAuthorization(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            return
        }

        supabaseService.signInWithIdToken(provider: .apple, idToken: idTokenString)
            .flatMap { [weak self] response -> Single<LoginModel> in
                guard let email = response.user.email else { return Single.error(RxError.noElements) }
                guard let self = self else { return Single.error(RxError.unknown) }
                return self.signinWhatfle(loginInfo: .appleLogin(email, response.user.id.uuidString.lowercased(), response.accessToken))
            }
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.router?.closeLogin()
            })
            .disposed(by: disposeBag)
    }

    func didCompleteWithError(error: Error) {
        // TODO: 애플 로그인 실패처리
    }
}