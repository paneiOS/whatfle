//
//  AppleLoginHelperDelegate.swift
//  What?fle
//
//  Created by 23 09 on 7/9/24.
//

import Foundation
import AuthenticationServices

protocol AppleLoginHelperDelegate: AnyObject {
    func didCompleteWithAuthorization(authorization: ASAuthorization)
    func didCompleteWithError(error: Error)
}

class AppleLoginHelper: NSObject {
    weak var delegate: AppleLoginHelperDelegate?

    func startAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AppleLoginHelper: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        delegate?.didCompleteWithAuthorization(authorization: authorization)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        delegate?.didCompleteWithError(error: error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }!
    }
}
