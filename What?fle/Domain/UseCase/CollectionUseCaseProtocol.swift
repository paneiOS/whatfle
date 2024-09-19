//
//  CollectionUseCaseProtocol.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import UIKit

import Moya
import RxSwift

protocol CollectionUseCaseProtocol {
    func getRecommendHashtag() -> Single<[RecommendHashTagModel]>
    func registCollection(collection: CollectionData, imageData: Data?) -> Single<Response>
    func getHomeData(page: Int, pageSize: Int) -> Single<HomeDataModel>
}

final class CollectionUseCase: CollectionUseCaseProtocol {
    private let collectionRepository: CollectionRepositoryProtocol

    init(collectionRepository: CollectionRepositoryProtocol) {
        self.collectionRepository = collectionRepository
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

    func getHomeData(page: Int, pageSize: Int) -> Single<HomeDataModel> {
        return collectionRepository.getHomeData(page: page, pageSize: pageSize)
    }
}
