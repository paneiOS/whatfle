//
//  NetworkService.swift
//  What?fle
//
//  Created by 이정환 on 2/28/24.
//

import Foundation

import Moya
import Supabase
import RxSwift

protocol NetworkServiceDelegate: AnyObject {
    func request<T: TargetType>(_ target: T) -> Single<Response>
    func requestDecodable<T: TargetType, U: Decodable>(_ target: T, type: U.Type) -> Single<U>
    func signInWithIDToken(provider: OpenIDConnectCredentials.Provider, idToken: String) -> Single<Supabase.Session>
}

final class NetworkService: NetworkServiceDelegate {
    private let provider: MoyaProvider<MultiTarget>
    private var client: SupabaseClient

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
                    print("signInWithIDToken_error", error)
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    private func refreshSessionIfNeeded() -> Single<String> {
        return Single.create {[weak self] single in
            guard let self else {
                single(.failure(NSError(domain: "RefreshSessionError", code: -1, userInfo: nil)))
                return Disposables.create()
            }
            Task {
                do {
                    let token = KeychainManager.loadAccessToken()
                    if self.isTokenValid(token) {
                        single(.success(token))
                    } else {
                        let session = try await self.client.auth.refreshSession()
                        try KeychainManager.saveAccessToken(token: session.accessToken)
                        single(.success(session.accessToken))
                    }
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func request<T: TargetType>(_ target: T) -> Single<Response> {
        return refreshSessionIfNeeded().flatMap { token in
            Single<Response>.create { [weak self] single in
                guard let self = self else {
                    single(.failure(NSError(domain: "RequestError", code: -1, userInfo: nil)))
                    return Disposables.create()
                }

                let requestTarget = MultiTarget(target)
                var headers = requestTarget.headers ?? [:]

                if !(target is KakaoAPI)
                    && !(target.path.contains("retriveRegistLocation")) {
                    headers["Authorization"] = "Bearer \(token)"
                }

                let endpoint = self.provider.endpointClosure(requestTarget)
                var request = try? endpoint.urlRequest()
                request?.allHTTPHeaderFields = headers

                let cancellable = self.provider.request(requestTarget) { result in
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
    }

    func requestDecodable<T: TargetType, U: Decodable>(_ target: T, type: U.Type) -> Single<U> {
        return request(target).map { response in
            return try JSONDecoder().decode(U.self, from: response.data)
        }
    }

    private func isTokenValid(_ token: String) -> Bool {
        guard let expirationDate = decodeJWT(token)?.expirationDate else {
            return false
        }

        return expirationDate > Date()

        func decodeJWT(_ token: String) -> (expirationDate: Date?, otherClaims: [String: Any]?)? {
            let segments = token.split(separator: ".")
            guard segments.count == 3 else { return nil }

            let base64String = String(segments[1])
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let paddedLength = base64String.count + (4 - base64String.count % 4) % 4
            let paddedBase64String = base64String.padding(toLength: paddedLength, withPad: "=", startingAt: 0)

            guard let data = Data(base64Encoded: paddedBase64String),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let claims = json as? [String: Any],
                  let exp = claims["exp"] as? TimeInterval else {
                return nil
            }

            let expirationDate = Date(timeIntervalSince1970: exp)
            return (expirationDate, claims)
        }
    }
}
