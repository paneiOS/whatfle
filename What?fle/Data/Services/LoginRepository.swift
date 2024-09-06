//
//  UserRepository.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya
import RxSwift
import Supabase

final class LoginRepository: LoginRepositoryProtocol {
    private let networkService: NetworkServiceDelegate
    private var client: SupabaseClient

    typealias Task = _Concurrency.Task
    
    var sessionManager: SessionManager {
        self.networkService.sessionManager
    }

    init(networkService: NetworkServiceDelegate) {
        self.networkService = networkService
        self.client = SupabaseClient(
            supabaseURL: URL(string: AppConfigs.API.Supabase.baseURL)!,
            supabaseKey: AppConfigs.API.Supabase.key
        )
    }

    func snsLogin(model: LoginRequestModel) -> Single<UserInfo> {
        return networkService.request(LoginAPI.snsLogin(model))
    }

    func signInWithIDToken(provider: OpenIDConnectCredentials.Provider, idToken: String) -> Single<Supabase.Session> {
        return Single.create { single in
            Task {
                do {
                    let response = try await self.client.auth.signInWithIdToken(
                        credentials: .init(
                            provider: provider,
                            idToken: idToken
                        )
                    )
                    single(.success(response))
                } catch {
                    errorPrint(error)
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func existNickname(nickname: String) -> Single<Bool> {
        return networkService.request(LoginAPI.existNickname(nickname))
    }

    func uploadImage(imageData: Data, fileName: String) -> Single<String> {
        return networkService.uploadImageRequest(
            bucketName: "profile",
            imageData: imageData,
            fileName: fileName
        )
    }

    func updateUserProfile(userProfile: UserProfile) -> Single<UserInfo> {
        return networkService.request(LoginAPI.updateProfile(userProfile))
    }
}
