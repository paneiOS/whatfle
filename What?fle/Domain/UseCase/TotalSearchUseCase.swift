//
//  TotalSearchUseCase.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import UIKit

import Moya
import RxSwift

protocol TotalSearchUseCaseProtocol {
    func getSearchRecommendTag() -> Single<[String]>
}

final class TotalSearchUseCase: TotalSearchUseCaseProtocol {
    private let totalSearchRepository: TotalSearchRepositoryProtocol

    init(totalSearchRepostory: TotalSearchRepositoryProtocol) {
        self.totalSearchRepository = totalSearchRepostory
    }

    func getSearchRecommendTag() -> Single<[String]> {
        return totalSearchRepository.getSearchRecommendTag()
            .map { tags in
                tags.map { $0.hashtagName }
            }
    }
}