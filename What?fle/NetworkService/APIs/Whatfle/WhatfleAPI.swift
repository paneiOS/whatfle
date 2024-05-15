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
    case retriveRegistLocation
}

extension WhatfleAPI: TargetType {
    var method: Moya.Method {
        switch self {
        case .registerPlace, .uploadPlaceImage:
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
                "imageUrls": registration.imageUrls ?? [],
                "latitude": registration.latitude,
                "longitude": registration.longitude
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
        case .registerPlace:
            return URL(string: AppConfigs.API.BaseURL.dev)!
        case .retriveRegistLocation:
            return URL(string: AppConfigs.API.BaseURL.Kakao.search)!
        case .uploadPlaceImage:
            return URL(string: AppConfigs.API.BaseURL.dev)!
        }
    }

    var path: String {
        switch self {
        case .registerPlace:
            return "/place"
        case .uploadPlaceImage:
            return "/image/place"
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
        default:
            return Data()
        }
    }
}