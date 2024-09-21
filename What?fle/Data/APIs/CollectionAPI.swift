//
//  CollectionAPI.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya

enum CollectionAPI: Loginable {
    case registCollectionData(CollectionDataModel)
    case getDetailCollection(Int)
    case getAllMyCollectionIDsWithFavorite
    case getHomeData(page: Int, pageSize: Int)
    case getRecommendHashtag
    case updateFavorite(id: Int, isFavorite: Bool)

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
        case .getAllMyCollectionIDsWithFavorite:
            return basePath + "/favorite/collection/ids/all"
        case .getDetailCollection(let id):
            return basePath + "/collection/\(id)"
        case .getHomeData:
            return basePath + "/home"
        case .getRecommendHashtag:
            return basePath + "/hashtag/recommend"
        case .registCollectionData:
            return basePath + "/collection"
        case .updateFavorite:
            return basePath + "/favorite/collection"
        }
    }

    var method: Moya.Method {
        switch self {
        case .registCollectionData:
            return .post
        case .updateFavorite:
            return .put
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getHomeData(let page, let pageSize):
            return .requestParameters(
                parameters: ["page": page, "pageSize": pageSize],
                encoding: URLEncoding.queryString
            )
        case .registCollectionData(let model):
            return .requestJSONEncodable(model)
        case .updateFavorite(let id, let isFavorite):
            return .requestParameters(
                parameters: ["collectionId": id, "isFavorite": isFavorite ? "true" : " false"],
                encoding: URLEncoding.queryString
            )
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            guard let accessToken = SessionManager.shared.activeToken else {
                return ["Authorization": ""]
            }
            return ["Authorization": "Bearer " + accessToken]
        }
    }

    var sampleData: Data {
        switch self {
        case .getDetailCollection:
            guard let path = Bundle.main.path(forResource: "DetailCollection", ofType: "json"),
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
