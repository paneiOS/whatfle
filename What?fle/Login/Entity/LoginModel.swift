//
//  LoginModel.swift
//  What?fle
//
//  Created by 23 09 on 7/3/24.
//

import Foundation

// MARK: - LoginModel
struct LoginModel: Decodable {
    let id: Int
    let thirdPartyAuthType: String
    let thirdPartyAuthUid: String
    let nickname: String?
    let profileImagePath: String?
    let email: String?
    let createdAt: String
    let updatedAt: String?
    let deletedAt: String?
    let isAgreement: Bool
}
