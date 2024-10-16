//
//  LoginAPI.swift
//  What?fle
//
//  Created by 이정환 on 8/25/24.
//

import UIKit

import Moya

protocol Loginable {
    var requiresLogin: Bool { get }
}

enum LoginAPI: Loginable {
    case existNickname(String)
    case signinAgreement([TermsAgreement])
    case snsLogin(LoginRequestModel)
    case updateProfile(UserProfile)
    case getUserInfo

    var requiresLogin: Bool {
        switch self {
        default:
            return true
        }
    }
}

extension LoginAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppConfigs.API.Supabase.baseURL)!
    }

    var path: String {
        let basePath: String = "/functions/v1/whatfle"
        switch self {
        case .existNickname(let nickname):
            return basePath + "/account/nickname/exist/\(nickname)"
        case .signinAgreement:
            return basePath + "/agreement"
        case .snsLogin:
            return basePath + "/account/signin"
        case .updateProfile:
            return basePath + "/account/profile"
        case .getUserInfo:
            return basePath + "/account"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signinAgreement,
             .snsLogin,
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

        case .signinAgreement(let model):
            return .requestJSONEncodable(model)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        guard let accessToken = SessionManager.shared.loadAccessToken() else {
            return ["Authorization": ""]
        }
        return ["Authorization": "Bearer " + accessToken]
    }
}
