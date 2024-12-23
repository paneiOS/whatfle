//
//  LoginUseCase.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import UIKit

import Moya
import RxSwift
import Supabase

protocol LoginUseCaseProtocol {
    func existNickname(nickname: String) -> Single<Bool>
    func loginInWithIDToken(provider: OpenIDConnectCredentials.Provider, idToken: String) -> Single<(Bool, Bool)>
    func sendTermsAgreement(agreements: [TermsAgreement]) -> Single<UserInfo>
    func updateUserProfile(nickname: String, imageData: Data?) -> Single<Void>
    func getUserInfo() -> Single<UserInfo>
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let loginRepository: LoginRepositoryProtocol

    init(loginRepository: LoginRepositoryProtocol) {
        self.loginRepository = loginRepository
    }

    func sendTermsAgreement(agreements: [TermsAgreement]) -> Single<UserInfo> {
        return loginRepository.sendTermsAgreement(agreements: agreements)
    }

    func snsLogin(model: LoginRequestModel) -> Single<UserInfo> {
        return loginRepository.snsLogin(model: model)
    }

    func loginInWithIDToken(provider: OpenIDConnectCredentials.Provider, idToken: String) -> Single<(Bool, Bool)> {
        return loginRepository.signInWithIDToken(provider: provider, idToken: idToken)
            .flatMap { [weak self] response -> Single<(Bool, Bool)> in
                guard let self,
                      let email = response.user.email else {
                    return Single.error(RxError.noElements)
                }
                let model: LoginRequestModel = .init(
                    email: email,
                    uuid: response.user.id.uuidString.lowercased(),
                    accessToken: response.accessToken,
                    snsType: .APPLE
                )
                loginRepository.sessionManager.login(token: response.accessToken)
                return self.loginRepository.snsLogin(model: model)
                    .map { ($0.isSignupRequired, $0.isProfileRequired) }
            }
    }

    func existNickname(nickname: String) -> Single<Bool> {
        return loginRepository.existNickname(nickname: nickname)
    }

    func updateUserProfile(nickname: String, imageData: Data?) -> Single<Void> {
        guard let imageData else {
            return self.loginRepository.updateUserProfile(userProfile: .init(nickname: nickname, profileImagePath: nil))
                .do(onSuccess: { [weak self] userInfo in
                    guard let self else { return }
                    self.loginRepository.sessionManager.saveUserInfo(userInfo)
                })
                .mapToVoid()
        }
        let fileName = "\(UUID().uuidString)_\(Int(Date().timeIntervalSince1970)).jpg"
        return self.loginRepository.uploadImage(imageData: imageData, fileName: fileName)
            .flatMap { [weak self] imageURL -> Single<UserInfo> in
                guard let self else {
                    return Single.error(RxError.noElements)
                }
                return self.loginRepository.updateUserProfile(
                    userProfile: .init(nickname: nickname, profileImagePath: imageURL)
                )
            }
            .do(onSuccess: { [weak self] userInfo in
                guard let self else { return }
                self.loginRepository.sessionManager.saveUserInfo(userInfo)
            })
            .mapToVoid()
    }

    func getUserInfo() -> Single<UserInfo> {
        return self.loginRepository.getUserInfo()
    }
}
