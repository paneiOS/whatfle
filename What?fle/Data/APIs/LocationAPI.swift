//
//  LocationAPI.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import Foundation

import Moya

enum LocationAPI: Loginable {
    case getAllMyPlace
    case registPlace(PlaceRegistration)
    case retriveRegistLocation
    case search(_ query: String, _ page: Int)

    var requiresLogin: Bool {
        switch self {
        default:
            return true
        }
    }
}

extension LocationAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .search, .retriveRegistLocation:
            return URL(string: AppConfigs.API.Kakao.searchURL)!
        default:
            return URL(string: AppConfigs.API.Supabase.baseURL)!
        }
    }

    var path: String {
        let basePath: String = "/functions/v1/whatfle"
        switch self {
        case .search:
            return "search/keyword"
        case .registPlace:
            return basePath + "/place"
        case .getAllMyPlace:
            return basePath + "/places"
        default:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .registPlace:
            return .post
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .registPlace(let model):
            return .requestJSONEncodable(model)
        case .retriveRegistLocation:
            let parameters: [String: Any] = [:]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .search(let query, let page):
            let parameters: [String: Any] = [
                "query": query,
                "page": page
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .search:
            return ["Authorization": "KakaoAK \(AppConfigs.API.Kakao.restKey)"]
        default:
            guard let accessToken = SessionManager.shared.loadAccessToken() else {
                return ["Authorization": ""]
            }
            return ["Authorization": "Bearer " + accessToken]
        }
    }

    var sampleData: Data {
        switch self {
        case .search:
            guard let path = Bundle.main.path(forResource: "SearchMock", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
            }
            return data
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
