//
//  CollectionAPI.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya

enum CollectionAPI: Loginable {
    case getRecommendHashtag
    case registCollectionData(CollectionDataModel)

    var requiresLogin: Bool {
        switch self {
        default:
            return true
        }
    }
}

extension CollectionAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppConfigs.API.Supabase.baseURL)!
    }

    var path: String {
        let basePath: String = "/functions/v1/whatfle"
        switch self {
        case .getRecommendHashtag:
            return basePath + "/hashtag/recommend"
        case .registCollectionData:
            return basePath + "/collection"
        }
    }

    var method: Moya.Method {
        switch self {
        case .registCollectionData:
            return .post
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .registCollectionData(let model):
            return .requestJSONEncodable(model)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        guard let accessToken = KeychainManager.shared.loadAccessToken() else {
            return ["Authorization": ""]
        }
        return ["Authorization": "Bearer " + accessToken]
    }

    var sampleData: Data {
        switch self {
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
