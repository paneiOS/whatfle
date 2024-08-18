//
//  KakaoAPI.swift
//  What?fle
//
//  Created by 이정환 on 2/29/24.
//

import Foundation
import Moya

enum KakaoAPI {
    case search(_ query: String, _ page: Int)
}

extension KakaoAPI: TargetType {
    var method: Moya.Method {
        switch self {
        case .search:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .search(let query, let page):
            let parameters: [String: Any] = [
                "query": query,
                "page": page
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return [
            "Authorization": "KakaoAK \(AppConfigs.API.Kakao.restKey)"
        ]
    }

    var baseURL: URL {
        return URL(string: AppConfigs.API.Kakao.searchURL)!
    }

    var path: String {
        switch self {
        case .search:
            return "search/keyword"
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
        }
    }
}
