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
    func getAllMyCollectionIDsWithFavorite() -> Single<[Int]>
    func getHomeData(page: Int, pageSize: Int) -> Single<HomeDataModel>
    func getRecommendHashtag() -> Single<[RecommendHashTagModel]>
    func registCollection(collection: CollectionDataModel) -> Single<Response>
    func uploadImage(imageData: Data, fileName: String) -> Single<String>
    func updateFavoriteLocation(id: Int, isFavorite: Bool) -> Single<Void>
    func updateFavoriteCollection(id: Int, isFavorite: Bool) -> Single<Void>
    func getMyPageData() -> Single<MyPageDataModel>
    func getMyFavoriteLocation() -> Single<[HomeDataModel.Collection.Place]>
    func getMyFavoriteCollection() -> Single<[HomeDataModel.Collection]>
}
