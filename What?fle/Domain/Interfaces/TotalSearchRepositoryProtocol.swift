//
//  TotalSearchRepositoryProtocol.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import Foundation

import RxSwift

protocol TotalSearchRepositoryProtocol {
    func getSearchRecommendTag() -> Single<[RecommendHashTagModel]>
}
