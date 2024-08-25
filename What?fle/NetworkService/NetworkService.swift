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
                        debugPrint("accessToken", session.accessToken)
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
        return refreshSessionIfNeeded().flatMap { [weak self] token in
            guard let self = self else {
                return Single.error(NSError(domain: "RequestError", code: -1, userInfo: nil))
            }

            var headers = target.headers ?? [:]
            headers["Authorization"] = "Bearer \(token)"

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
    }

    func request<T: TargetType, U: Decodable>(_ target: T) -> Single<U> {
        return refreshSessionIfNeeded().flatMap { [weak self] token in
            guard let self = self else {
                return Single.error(NSError(domain: "RequestError", code: -1, userInfo: nil))
            }

            var headers = target.headers ?? [:]
            headers["Authorization"] = "Bearer \(token)"

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
    }

    func uploadImageRequest(bucketName: String, imageData: Data, fileName: String) -> Single<String> {
        return refreshSessionIfNeeded().flatMap { [weak self] token in
            guard let self = self else {
                return Single.error(NSError(domain: "UploadError", code: -1, userInfo: nil))
            }

            self.client = SupabaseClient(
                supabaseURL: URL(string: AppConfigs.API.Supabase.baseURL)!,
                supabaseKey: token
            )

            return Single<String>.create { single in
                Task {
                    do {
                        let response = try await self.client.storage.from(bucketName).upload(path: fileName, file: imageData)
                        let fileURL = try self.client.storage.from(bucketName).getPublicURL(path: response.id).absoluteString
                        single(.success(fileURL))
                    } catch {
                        print("uploadImage_error", error)
                        single(.failure(error))
                    }
                }
                return Disposables.create()
            }
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
