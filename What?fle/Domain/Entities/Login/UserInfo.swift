//
//  UserInfo.swift
//  What?fle
//
//  Created by 이정환 on 8/16/24.
//

import Foundation

struct UserInfo: Codable {
    let id: Int
    let thirdPartyAuthType: String
    let thirdPartyAuthUid: String
    let nickname: String
    let profileImagePath: String?
    let email: String?
    let createdAt: String
    let updatedAt: String?
    let deletedAt: String?
    let isAgreement: Bool
}
