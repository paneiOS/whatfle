//
//  LoginUseCaseProtocol.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import RxSwift
import Supabase

protocol LoginRepositoryProtocol {
    var sessionManager: SessionManager { get }
    func sendTermsAgreement(agreements: [TermsAgreement]) -> Single<UserInfo>
    func snsLogin(model: LoginRequestModel) -> Single<UserInfo>
    func signInWithIDToken(provider: OpenIDConnectCredentials.Provider, idToken: String) -> Single<Supabase.Session>
    func existNickname(nickname: String) -> Single<Bool>
    func uploadImage(imageData: Data, fileName: String) -> Single<String>
    func updateUserProfile(userProfile: UserProfile) -> Single<UserInfo>
}
