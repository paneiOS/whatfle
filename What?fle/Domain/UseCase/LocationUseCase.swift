//
//  LocationUseCase.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import UIKit

import Moya
import RxSwift

protocol LocationUseCaseProtocol {
    func search(_ query: String, _ page: Int) -> Single<[KakaoSearchDocumentsModel]>
    func registPlace(registration: PlaceRegistration, imageData: [Data]) -> Single<Response>
    func getAllMyPlace() -> Single<[(date: String, places: [PlaceRegistration])]>
}

final class LocationUseCase: LocationUseCaseProtocol {
    private let locationRepository: LocationRepositoryProtocol

    init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    func search(_ query: String, _ page: Int) -> Single<[KakaoSearchDocumentsModel]> {
        return locationRepository.search(query, page)
            .map {
                $0.documents
            }
    }

    func registPlace(registration: PlaceRegistration, imageData: [Data]) -> Single<Response> {
        let fileNames = (0...imageData.count).map { _ in "\(UUID().uuidString)_\(Int(Date().timeIntervalSince1970)).jpg" }
        return locationRepository.uploadImages(imageData: imageData, fileNames: fileNames)
            .flatMap { [weak self] imageURLs in
                guard let self else {
                    return Single.error(RxError.noElements)
                }
                return self.locationRepository.registPlace(registration: .init(registration: registration, imageURLs: imageURLs))
            }
    }

    func getAllMyPlace() -> Single<[(date: String, places: [PlaceRegistration])]> {
        return locationRepository.getAllMyPlace().map { $0.groupedByDate() }
    }
}
