//
//  NetworkService.swift
//  What?fle
//
//  Created by 이정환 on 2/28/24.
//

import Foundation
import Moya
import RxSwift

protocol NetworkServiceDelegate: AnyObject {
    func request<T: TargetType>(_ target: T) -> Single<Response>
    func requestDecodable<T: TargetType, U: Decodable>(_ target: T, type: U.Type) -> Single<U>
}

final class NetworkService: NetworkServiceDelegate {
    private let provider: MoyaProvider<MultiTarget>

    init(isStubbing: Bool = false) {
        if isStubbing {
            self.provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            self.provider = MoyaProvider<MultiTarget>()
        }
    }

    func request<T: TargetType>(_ target: T) -> Single<Response> {
        return Single<Response>.create { [weak provider] single in
            let requestTarget = MultiTarget(target)
            let cancellable = provider?.request(requestTarget) { result in
                switch result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create {
                cancellable?.cancel()
            }
        }
    }

    func requestDecodable<T: TargetType, U: Decodable>(_ target: T, type: U.Type) -> Single<U> {
            return request(target).map { response in
                return try JSONDecoder().decode(U.self, from: response.data)
            }
        }
}
