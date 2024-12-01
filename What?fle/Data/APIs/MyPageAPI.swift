//
//  MyPageAPI.swift
//  What?fle
//
//  Created by 이정환 on 11/6/24.
//

import Foundation

import Moya

enum MyPageAPI: Loginable {
    case getMyPageData
    case getMyFavoriteCollection
    case getMyFavoriteLocation
    case getMyFavoriteLocationIDs

    var requiresLogin: Bool {
        switch self {
        default:
            return true
        }
    }
}

extension MyPageAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppConfigs.API.Supabase.baseURL)!
    }

    var path: String {
        let basePath: String = "/functions/v1/whatfle"
        switch self {
        case .getMyPageData:
            return basePath + "/mypage"
        case .getMyFavoriteCollection:
            return basePath + "/favorite/collection/all"
        case .getMyFavoriteLocation:
            return basePath + "/favorite/place/all"
        case .getMyFavoriteLocationIDs:
            return basePath + "/favorite/place/ids/all"
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
        case .getMyPageData:
            guard let path = Bundle.main.path(forResource: "MyPageDataMock", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
            }
            return data
        default:
            return Data()
        }
    }
}
