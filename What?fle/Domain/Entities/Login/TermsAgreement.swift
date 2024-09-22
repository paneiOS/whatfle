//
//  TermsAgreement.swift
//  What?fle
//
//  Created by 이정환 on 9/22/24.
//

import Foundation

struct TermsAgreement: Encodable {
    let agreementType: AgreementType
    let isAgreed: Bool
}

enum AgreementType: String, Encodable {
    case service = "ServiceUse"
    case privacy = "PersonalInformationProcess"
    case marketing = "Marketing"
}
