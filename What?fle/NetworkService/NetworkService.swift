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
    var sessionManager: SessionManager { get }
    var isLogin: Bool { get }
    func request<T: TargetType>(_ target: T) -> Single<Response>
    func request<T: TargetType, U: Decodable>(_ target: T) -> Single<U>
    func uploadImageRequest(bucketName: String, imageData: Data, fileName: String) -> Single<String>
    func monitorAuthChanges() async
}

final class NetworkService: NetworkServiceDelegate {
    private let provider: MoyaProvider<MultiTarget>
    private var client: SupabaseClient
    let sessionManager: SessionManager
    private let disposeBag = DisposeBag()

    typealias Task = _Concurrency.Task

    var isLogin: Bool {
        sessionManager.isLogin
    }

    init(isStubbing: Bool = false, sessionManager: SessionManager = .shared) {
        if isStubbing {
            self.provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            self.provider = MoyaProvider<MultiTarget>()
        }
        self.client = SupabaseClient(
            supabaseURL: URL(string: AppConfigs.API.Supabase.baseURL)!,
            supabaseKey: AppConfigs.API.Supabase.key
        )
        self.sessionManager = sessionManager
    }

    func monitorAuthChanges() async {
        Task {
            if !sessionManager.isLogin {
                logPrint("사용자는 로그아웃 상태입니다.", "익명 액세스 토큰을 사용합니다.")
                await handleAnonymousSession()
            } else {
                if let session = try? await self.client.auth.session {
                    sessionManager.login(token: session.accessToken, for: .member, "로그인 상태를 초기화합니다.")
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
                logPrint("현재 유저", change.session?.user)
                logPrint("현재 유저메타데이터", change.session?.user.userMetadata)

                switch change.event {
                case .initialSession:
                    if let userMetadata = change.session?.user.userMetadata, !userMetadata.isEmpty {
                        sessionManager.login(token: accessToken, for: .member, "세션을 초기화하였습니다.")
                    } else {
                        sessionManager.login(token: accessToken, for: .guest, "세션을 초기화하였습니다.")
                    }

                case .signedIn:
                    sessionManager.login(token: accessToken, "로그인되었습니다.")
                case .tokenRefreshed:
                    if sessionManager.isLogin {
                        sessionManager.login(token: accessToken, "토큰이 갱신되었습니다.")
                    }
                case .signedOut:
                    sessionManager.logout(accessToken, "로그아웃 처리되었습니다.")
                    await handleAnonymousSession()
                case .userDeleted:
                    sessionManager.logout(accessToken, "탈퇴 처리되었습니다.")
                    await handleAnonymousSession()
                default:
                    sessionManager.login(token: accessToken, "기타 인증 이벤트가 발생했습니다.")
                }
            }
        }
    }

    private func handleAnonymousSession() async {
        do {
            let session = try await self.client.auth.signInAnonymously()
            sessionManager.login(token: session.accessToken, for: .guest, "익명 세션이 설정되었습니다.")
        } catch {
            sessionManager.logout(error.localizedDescription, "익명 세션 설정에 실패했습니다.")
        }
    }

    func request<T: TargetType>(_ target: T) -> Single<Response> {
        return Single<Response>.create { single in
            let cancellable = self.provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        logPrint(
                            "응답값 상태 \(response.statusCode)",
                            "타겟타입: \(target)",
                            "Received JSON data ",
                            jsonString
                        )
                    } else {
                        logPrint("Failed to convert data to JSON string")
                    }
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
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        logPrint(
                            "응답값 상태 \(response.statusCode)",
                            "타겟타입: \(target)",
                            "Received JSON data ",
                            jsonString
                        )
                    } else {
                        logPrint("Failed to convert data to JSON string")
                    }
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
