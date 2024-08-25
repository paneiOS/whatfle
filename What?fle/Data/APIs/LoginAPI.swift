//
//  LoginAPI.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import UIKit

import Moya

enum LoginAPI {
    case snsLogin(LoginRequestModel)
    case existNickname(String)
    case updateProfile(UserProfile)
}

extension LoginAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppConfigs.API.Supabase.baseURL)!
    }

    var path: String {
        let basePath: String = "/functions/v1/whatfle"
        switch self {
        case .snsLogin:
            return basePath + "/account/signin"
        case .existNickname(let nickname):
            return basePath + "/account/nickname/exist/\(nickname)"
        case .updateProfile:
            return basePath + "/account/profile"
        }
    }

    var method: Moya.Method {
        switch self {
        case .snsLogin,
             .updateProfile:
            return .post
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .snsLogin(let model):
            let parameters: [String: Any] = [
                "email": model.email,
                "thirdPartyAuthType": model.snsType.rawValue,
                "thirdPartyAuthUid": model.uuid
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .updateProfile(let model):
            return .requestJSONEncodable(model)

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Authorization": "Bearer " + KeychainManager.loadAccessToken()]
    }
}
