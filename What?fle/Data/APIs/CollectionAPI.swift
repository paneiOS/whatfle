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
    case updateFavoriteLocation(id: Int, isFavorite: Bool)
    case updateFavoriteCollection(id: Int, isFavorite: Bool)

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
        case .updateFavoriteLocation:
            return basePath + "/favorite/place"
        case .updateFavoriteCollection:
            return basePath + "/favorite/collection"
        }
    }

    var method: Moya.Method {
        switch self {
        case .registCollectionData:
            return .post
        case .updateFavoriteLocation, .updateFavoriteCollection:
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
        case .updateFavoriteLocation(let id, let isFavorite):
            return .requestParameters(
                parameters: ["placeId": id, "isFavorite": isFavorite ? "true" : " false"],
                encoding: URLEncoding.queryString
            )
        case .updateFavoriteCollection(let id, let isFavorite):
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
