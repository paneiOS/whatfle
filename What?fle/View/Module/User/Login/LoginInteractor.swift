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

protocol LoginRouting: ViewableRouting {
    var navigationController: UINavigationController? { get }
    func pushProfileRIB(isProfileRequired: Bool)
    func popToProfileView()
}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

protocol LoginListener: AnyObject {
    func proceedToNextScreenAfterLogin()
    func dismissLoginRIB()
}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable, LoginPresentableListener {

    weak var router: LoginRouting?
    weak var listener: LoginListener?

    private let loginUseCase: LoginUseCaseProtocol
    private let disposeBag = DisposeBag()

    deinit {
        deinitPrint()
    }

    init(
        presenter: LoginPresentable,
        loginUseCase: LoginUseCaseProtocol
    ) {
        self.loginUseCase = loginUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension LoginInteractor {
    func appleLogin(idToken: String) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()
        loginUseCase.loginInWithIDToken(provider: .apple, idToken: idToken)
            .flatMap { [weak self] isSignupRequired, isProfileRequired -> Single<UserInfo> in
                guard let self else { return Single.error(NSError()) }
                if isSignupRequired {
                    self.router?.pushProfileRIB(isProfileRequired: isProfileRequired)
                    return Single.error(NSError())
                } else {
                    return self.loginUseCase.getUserInfo()
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] userInfo in
                guard let self else { return }
                SessionManager.shared.saveUserInfo(userInfo)
                self.listener?.proceedToNextScreenAfterLogin()
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext: {[weak self] oauthToken in
                    // TODO: - 카아오 로그인 오스토큰 발급, 이걸 supabase에 전달해야함.
                }, onError: {error in
                    errorPrint(error)
                })
                .disposed(by: disposeBag)
        } else {
            // TODO: - 카카오톡 설치 안된 케이스
        }
    }

    func closeLogin() {
        listener?.dismissLoginRIB()
    }

    func popToProfileView() {
        router?.popToProfileView()
    }
}
