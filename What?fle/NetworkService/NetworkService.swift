//
//  NetworkService.swift
//  What?fle
//
//  Created by 이정환 on 2/28/24.
//

import Foundation

import Moya
import Supabase
import Storage
import RxSwift

protocol NetworkServiceDelegate: AnyObject {
    func request<T: TargetType>(_ target: T) -> Single<Response>
    func request<T: TargetType, U: Decodable>(_ target: T) -> Single<U>
    func uploadImageRequest(bucketName: String, imageData: Data, fileName: String) -> Single<String>
}

final class NetworkService: NetworkServiceDelegate {
    private let provider: MoyaProvider<MultiTarget>
    private var client: SupabaseClient
    private let disposeBag = DisposeBag()

    typealias Task = _Concurrency.Task

    init(isStubbing: Bool = false) {
        if isStubbing {
            self.provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            self.provider = MoyaProvider<MultiTarget>()
        }
        self.client = SupabaseClient(
            supabaseURL: URL(string: AppConfigs.API.Supabase.baseURL)!,
            supabaseKey: AppConfigs.API.Supabase.key
        )

        monitorAuthChanges()
    }

    private func monitorAuthChanges() {
        Task {
            if KeychainManager.loadAccessToken().isEmpty {
                logPrint("사용자는 로그아웃 상태입니다.", "익명 액세스 토큰을 사용합니다.")
                await handleAnonymousSession()
            } else {
                if let session = try? await self.client.auth.session {
                    logPrint("로그인 상태를 초기화합니다.", session.accessToken)
                    KeychainManager.saveAccessToken(token: session.accessToken)
                } else {
                    logPrint("로그인 상태가 아닙니다.", "새로운 세션을 시도합니다.")
                    await handleAnonymousSession()
                }
            }

            for await change in self.client.auth.authStateChanges {
                guard let accessToken = change.session?.accessToken else {
                    logPrint("세션이 유효하지 않습니다.", "익명 액세스 토큰을 사용합니다.")
                    await handleAnonymousSession()
                    continue
                }

                logPrint("현재 상태", change.event)
                switch change.event {
                case .signedIn, .tokenRefreshed:
                    logPrint("로그인 또는 토큰 갱신되었습니다.")
                    KeychainManager.saveAccessToken(token: accessToken)
                case .signedOut, .userDeleted:
                    logPrint("로그아웃 또는 탈퇴 처리되었습니다.")
                    KeychainManager.deleteAccessToken()
                    await handleAnonymousSession()
                default:
                    logPrint("기타 인증 이벤트가 발생했습니다.", change.event)
                    KeychainManager.saveAccessToken(token: accessToken)
                }
            }
        }
    }

    private func handleAnonymousSession() async {
        do {
            let session = try await self.client.auth.signInAnonymously()
            logPrint("익명 세션이 설정되었습니다.", session.accessToken)
            KeychainManager.saveAccessToken(token: session.accessToken)
        } catch {
            logPrint("익명 세션 설정에 실패했습니다.", error.localizedDescription)
            KeychainManager.deleteAccessToken()
        }
    }

    func request<T: TargetType>(_ target: T) -> Single<Response> {
        return Single<Response>.create { single in
            let cancellable = self.provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    single(.failure(error))
                }
            }

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }

    func request<T: TargetType, U: Decodable>(_ target: T) -> Single<U> {
        return Single<U>.create { single in
            let cancellable = self.provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(U.self, from: response.data)
                        single(.success(decodedResponse))
                    } catch {
                        single(.failure(error))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }

    func uploadImageRequest(bucketName: String, imageData: Data, fileName: String) -> Single<String> {
        return Single<String>.create { [weak self] single in
            guard let self else {
                return Disposables.create()
            }
            Task {
                do {
                    let response = try await self.client.storage.from(bucketName).upload(path: fileName, file: imageData)
                    let fileURL = try self.client.storage.from(bucketName).getPublicURL(path: response.id).absoluteString
                    single(.success(fileURL))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
