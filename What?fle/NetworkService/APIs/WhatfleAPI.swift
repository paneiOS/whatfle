//
//  WhatfleAPI.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import UIKit

import Moya

enum WhatfleAPI {
    case retriveRegistLocation
    case getDetailCollection(Int)
}

extension WhatfleAPI: TargetType {
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .retriveRegistLocation:
            let parameters: [String: Any] = [:]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
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
        case .getDetailCollection(let id):
            return basePath + "/collection/\(id)"
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
        case .getDetailCollection:
            guard let path = Bundle.main.path(forResource: "DetailCollection", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
            }
            return data
        }
    }
}
