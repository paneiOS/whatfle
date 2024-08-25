//
//  LocationRepository.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya
import RxSwift

final class LocationRepository: LocationRepositoryProtocol {
    private let networkService: NetworkServiceDelegate

    init(networkService: NetworkServiceDelegate) {
        self.networkService = networkService
    }

    func search(_ query: String, _ page: Int) -> Single<KakaoSearchModel> {
        return self.networkService.request(LocationAPI.search(query, page))
    }

    func uploadImages(imageData: [Data], fileNames: [String]) -> Single<[String]> {
        let uploadSingles = zip(imageData, fileNames).map {
            self.networkService.uploadImageRequest(bucketName: "place", imageData: $0, fileName: $1)
        }
        return Single.zip(uploadSingles)
    }

    func registPlace(registration: PlaceRegistration) -> Single<Response> {
        return self.networkService.request(LocationAPI.registPlace(registration))
    }

    func getAllMyPlace() -> Single<[PlaceRegistration]> {
        return self.networkService.request(LocationAPI.getAllMyPlace)
    }
}

extension Array where Element == PlaceRegistration {
    func groupedByDate() -> [(date: String, places: [PlaceRegistration])] {
        let groupedDictionary = Dictionary(grouping: self, by: { $0.visitDate.replaceHyphensWithDots() })
        let sortedKeys = groupedDictionary.keys.sorted(by: >)
        return sortedKeys.map { (date: $0, places: groupedDictionary[$0]!) }
    }
}
