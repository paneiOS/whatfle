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
    case getDetailCollection(Int)
    case appleLogin(LoginRequestModel)
}

extension WhatfleAPI: TargetType {
    var method: Moya.Method {
        switch self {
        case .registerPlace,
             .registCollectionData,
             .uploadPlaceImage,
             .appleLogin:
            return .post
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .registerPlace(let model):
            return .requestJSONEncodable(model)

        case .registCollectionData(let model):
            return .requestJSONEncodable(model)

        case .retriveRegistLocation:
            let parameters: [String: Any] = [:]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case .uploadPlaceImage(let images):
            var multipartData: [MultipartFormData] = []
            for (index, image) in images.enumerated() {
                if let imageData = image.resizedImageWithinKilobytes(kilobytes: 10) {
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

        case .appleLogin(let model):
            let parameters: [String: Any] = [
                "email": model.email,
                "thirdPartyAuthType": "APPLE",
                "thirdPartyAuthUid": model.uuid
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .retriveRegistLocation:
            return ["Authorization": ""]
        default:
            return ["Authorization": "Bearer " + KeychainManager.loadAccessToken()]
        }
    }

    var baseURL: URL {
        switch self {
        case .retriveRegistLocation:
            return URL(string: AppConfigs.API.Kakao.searchURL)!
        default:
            return URL(string: AppConfigs.API.Supabase.baseURL)!
        }
    }

    var path: String {
        let basePath: String = "/functions/v1/whatfle"
        switch self {
        case .registerPlace:
            return basePath + "/place"
        case .registCollectionData:
            return basePath + "/collection"
        case .uploadPlaceImage:
            return basePath + "/image/place"
        case .getAllMyPlace:
            return basePath + "/places"
        case .getRecommendHashtag:
            return basePath + "/hashtag/recommend"
        case .getDetailCollection(let id):
            return basePath + "/collection/\(id)"
        case .appleLogin:
            return basePath + "/account/signin"
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
        case .getDetailCollection:
            guard let path = Bundle.main.path(forResource: "DetailCollection", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
            }
            return data
        default:
            return Data()
        }
    }
}
