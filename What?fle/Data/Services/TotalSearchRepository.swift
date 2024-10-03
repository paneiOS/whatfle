//
//  TotalSearchRepository.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import Foundation

import RxSwift

final class TotalSearchRepository: TotalSearchRepositoryProtocol {
    private let networkService: NetworkServiceDelegate
    
    init(networkService: NetworkServiceDelegate) {
        self.networkService = networkService
    }
    
    func getSearchRecommendTag() -> Single<[RecommendHashTagModel]> {
        return self.networkService.request(TotalSearchAPI.getSearchRecommendTag)
    }
}
