//
//  WhatfleAPI.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import UIKit
import Moya

enum WhatfleAPI {
    case uploadPlaceImage(images: [UIImage])
    case registerPlace(PlaceRegistration)
    case registCollectionData(CollectionDataModel)
    case retriveRegistLocation
    case getAllMyPlace
    case getRecommendHashtag
}

extension WhatfleAPI: TargetType {
    var method: Moya.Method {
        switch self {
        case .registerPlace,
             .registCollectionData,
             .uploadPlaceImage:
            return .post
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .registerPlace(let registration):
            let parameters: [String: Any] = [
                "accountId": registration.accountID,
                "description": registration.description,
                "visitDate": registration.visitDate,
                "placeName": registration.placeName,
                "address": registration.address,
                "roadAddress": registration.roadAddress,
                "imageUrls": registration.imageURLs ?? [],
                "latitude": registration.latitude,
                "longitude": registration.longitude
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .registCollectionData(let model):
            let parameters: [String: Any] = [
                "accountId": model.accountID,
                "title": model.title,
                "description": model.description,
                "isPublic": model.isPublic,
                "hashtags": model.hashtags,
                "places": model.places,
                "imageUrls": model.imageURls,
                "isActiveCover": model.isActiveCover
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .retriveRegistLocation:
            let parameters: [String: Any] = [:]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case .uploadPlaceImage(let images):
            var multipartData: [MultipartFormData] = []
            for (index, image) in images.enumerated() {
                if let imageData = image.resizedImageWithinMegabytes(megabytes: 10) {
                    let formData = MultipartFormData(
                        provider: .data(imageData),
                        name: "file\(index)",
                        fileName: "image\(index).jpg",
                        mimeType: "image/jpeg"
                    )
                    multipartData.append(formData)
                }
            }
            return .uploadMultipart(multipartData)

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .retriveRegistLocation:
            return ["Authorization": ""]
        default:
            return ["Authorization": "\(AppConfigs.API.Key.accessToken)"]
        }
    }

    var baseURL: URL {
        switch self {
        case .retriveRegistLocation:
            return URL(string: AppConfigs.API.BaseURL.Kakao.search)!
        default:
            return URL(string: AppConfigs.API.BaseURL.dev)!
        }
    }

    var path: String {
        switch self {
        case .registerPlace:
            return "/place"
        case .registCollectionData:
            return "/collection"
        case .uploadPlaceImage:
            return "/image/place"
        case .getAllMyPlace:
            return "/places"
        case .getRecommendHashtag:
            return "/hashtag/recommend"
        default:
            return ""
        }
    }

    var sampleData: Data {
        switch self {
        case .retriveRegistLocation:
            guard let path = Bundle.main.path(forResource: "RetriveRegistLocationMock", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
            }
            return data
        case .getRecommendHashtag:
            guard let path = Bundle.main.path(forResource: "RecommendHashTag", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
            }
            return data
        default:
            return Data()
        }
    }
}
