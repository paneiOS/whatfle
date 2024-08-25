//
//  LoginRequestModel.swift
//  What?fle
//
//  Created by JeongHwan Lee on 8/16/24.
//

import Foundation

struct LoginRequestModel {
    enum SNSType: String {
        case APPLE
        case KAKAO
    }
    let email: String
    let uuid: String
    let accessToken: String
    let snsType: SNSType
}
