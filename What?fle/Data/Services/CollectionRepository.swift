//
//  CollectionRepository.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya
import RxSwift

final class CollectionRepository: CollectionRepositoryProtocol {
    private let networkService: NetworkServiceDelegate

    init(networkService: NetworkServiceDelegate) {
        self.networkService = networkService
    }

    func getAllMyCollectionIDsWithFavorite() -> Single<[Int]> {
        return self.networkService.request(CollectionAPI.getAllMyCollectionIDsWithFavorite)
    }

    func getHomeData(page: Int, pageSize: Int) -> Single<HomeDataModel> {
        return self.networkService.request(CollectionAPI.getHomeData(page: page, pageSize: pageSize))
    }

    func getRecommendHashtag() -> Single<[RecommendHashTagModel]> {
        return self.networkService.request(CollectionAPI.getRecommendHashtag)
    }

    func uploadImage(imageData: Data, fileName: String) -> Single<String> {
        return networkService.uploadImageRequest(
            bucketName: "collection",
            imageData: imageData,
            fileName: fileName
        )
    }

    func registCollection(collection: CollectionDataModel) -> Single<Response> {
        return self.networkService.request(CollectionAPI.registCollectionData(collection))
    }

    func updateFavorite(id: Int, isFavorite: Bool) -> Single<Void> {
        return self.networkService.request(CollectionAPI.updateFavorite(id: id, isFavorite: isFavorite))
            .map { _ in () }
    }

    func getMyPageData() -> Single<MyPageDataModel> {
        return self.networkService.request(MyPageAPI.getMyPageData)
    }
}
