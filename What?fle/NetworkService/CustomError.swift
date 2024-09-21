//
//  CustomError.swift
//  What?fle
//
//  Created by 이정환 on 5/15/24.
//

enum CustomError: Error {
    case uploadError(String)
    case registrationError(String)

    var localizedDescription: String {
        switch self {
        case .uploadError(let message), .registrationError(let message):
            return message
        }
    }
}
