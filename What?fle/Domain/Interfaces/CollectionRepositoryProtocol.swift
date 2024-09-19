//
//  CollectionRepositoryProtocol.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya
import RxSwift

protocol CollectionRepositoryProtocol {
    func getRecommendHashtag() -> Single<[RecommendHashTagModel]>
    func uploadImage(imageData: Data, fileName: String) -> Single<String>
    func registCollection(collection: CollectionDataModel) -> Single<Response>
    func getHomeData(page: Int, pageSize: Int) -> Single<HomeDataModel>
}
