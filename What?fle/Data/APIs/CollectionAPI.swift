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
    case getHomeData(page: Int, pageSize: Int)

    var requiresLogin: Bool {
        switch self {
        case .getHomeData:
            return false
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
        case .getHomeData:
            return basePath + "/home"
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
        case .getHomeData(let page, let pageSize):
            return .requestParameters(
                parameters: ["page": page, "pageSize": pageSize],
                encoding: URLEncoding.queryString
            )
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getHomeData:
            guard let accessToken = SessionManager.shared.activeToken else {
                return ["Authorization": ""]
            }
            return ["Authorization": "Bearer " + accessToken]
        default:
            guard let accessToken = SessionManager.shared.loadAccessToken() else {
                return ["Authorization": ""]
            }
            return ["Authorization": "Bearer " + accessToken]
        }
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
