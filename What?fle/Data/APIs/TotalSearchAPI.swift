//
//  TotalSearchAPI.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import Foundation

import Moya

enum TotalSearchAPI: Loginable {
    case getSearchRecommendTag
    case getSearchTerm(term: String)

    var requiresLogin: Bool {
        switch self {
        case .getSearchRecommendTag, .getSearchTerm:
            return false
        }
    }
}

extension TotalSearchAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppConfigs.API.Supabase.baseURL)!
    }

    var path: String {
        let basePath: String = "/functions/v1/whatfle"
        switch self {
        case .getSearchRecommendTag:
            return basePath + "/hashtag/recommend"
        case .getSearchTerm:
            return basePath + "/search"
        }
    }

    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getSearchRecommendTag:
            return .requestParameters(
                parameters: ["size": 10],
                encoding: URLEncoding.queryString
            )
        case .getSearchTerm(let term):
            return .requestParameters(
                parameters: ["searchText": term],
                encoding: URLEncoding.queryString
            )
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
}
