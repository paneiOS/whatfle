//
//  RequiresLogin.swift
//  What?fle
//
//  Created by 이정환 on 9/9/24.
//

import Foundation

import RIBs

protocol LoginVerifiable: AnyObject {
    var isLogin: Bool { get }
    func showLoginIfNeeded(completion: @escaping () -> Void)
    func showLoginRIB(completion: @escaping (Bool) -> Void)
}

extension LoginVerifiable where Self: ViewableRouter<Interactable, ViewControllable> {
    func showLoginIfNeeded(completion: @escaping () -> Void) {
        if isLogin {
            completion()
        } else {
            showLoginRIB { success in
                if success {
                    completion()
                }
            }
        }
    }
}
