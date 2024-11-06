//
//  CollectionUseCase.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import UIKit

import Moya
import RxSwift

protocol CollectionUseCaseProtocol {
    func getHomeData(page: Int, pageSize: Int) -> Single<HomeDataModel>
    func getRecommendHashtag() -> Single<[RecommendHashTagModel]>
    func registCollection(collection: CollectionData, imageData: Data?) -> Single<Response>
    func updateFavorite(id: Int, isFavorite: Bool) -> Single<Void>
    func getMyPageData() -> Single<MyPageDataModel>
}

final class CollectionUseCase: CollectionUseCaseProtocol {
    private let collectionRepository: CollectionRepositoryProtocol

    init(collectionRepository: CollectionRepositoryProtocol) {
        self.collectionRepository = collectionRepository
    }

    func getHomeData(page: Int, pageSize: Int) -> Single<HomeDataModel> {
        if SessionManager.shared.isLogin {
            return Single.zip(
                collectionRepository.getHomeData(page: page, pageSize: pageSize),
                collectionRepository.getAllMyCollectionIDsWithFavorite()
            )
            .map { homeData, favoriteIDs in
                let updatedContents = homeData.contents.map { content -> HomeDataModel.Content in
                    let isFavorite = favoriteIDs.contains(content.collection.id)
                    return HomeDataModel.Content(data: content, isFavorite: isFavorite)
                }
                return HomeDataModel(
                    topSection: homeData.topSection,
                    contents: updatedContents,
                    page: homeData.page,
                    pageSize: homeData.pageSize,
                    isLastPage: homeData.isLastPage
                )
            }
        } else {
            return collectionRepository.getHomeData(page: page, pageSize: pageSize)
        }
    }

    func getRecommendHashtag() -> Single<[RecommendHashTagModel]> {
        return collectionRepository.getRecommendHashtag()
    }

    func registCollection(collection: CollectionData, imageData: Data?) -> Single<Response> {
        if let imageData = imageData {
            let fileName = "\(UUID().uuidString)_\(Int(Date().timeIntervalSince1970)).jpg"
            return collectionRepository.uploadImage(imageData: imageData, fileName: fileName)
                .flatMap { [weak self] imageURL in
                    guard let self else {
                        return Single.error(RxError.noElements)
                    }
                    return self.collectionRepository.registCollection(collection: .init(data: collection, imageURL: [imageURL]))
                }
        } else {
            return self.collectionRepository.registCollection(collection: .init(data: collection, imageURL: []))
        }
    }

    func updateFavorite(id: Int, isFavorite: Bool) -> Single<Void> {
        self.collectionRepository.updateFavorite(id: id, isFavorite: isFavorite)
    }

    func getMyPageData() -> Single<MyPageDataModel> {
        return collectionRepository.getMyPageData()
    }
}
