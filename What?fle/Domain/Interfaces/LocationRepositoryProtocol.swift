//
//  LocationRepositoryProtocol.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya
import RxSwift

protocol LocationRepositoryProtocol {
    func uploadImages(imageData: [Data], fileNames: [String]) -> Single<[String]>
    func search(_ query: String, _ page: Int) -> Single<KakaoSearchModel>
    func registPlace(registration: PlaceRegistration) -> Single<Response>
    func getAllMyPlace() -> Single<[PlaceRegistration]>
}
