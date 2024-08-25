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

    private let loginUseCase: LoginUseCaseProtocol
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
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
        loginUseCase.signInWithIDToken(provider: .apple, idToken: idToken)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] model in
                guard let self else { return }
                try? KeychainManager.saveUserInfo(model: model)
                self.router?.pushProfileRIB()
            }, onFailure: { error in
                print("\(self) Error:", error)
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
                    print("\(self) Error:", error)
                })
                .disposed(by: disposeBag)
        } else {
            // TODO: - 카카오톡 설치 안된 케이스
        }
    }

    func closeLogin() {
        listener?.dismissLoginRIB()
    }
}
