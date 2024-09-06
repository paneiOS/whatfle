//
//  AppDelegate.swift
//  What?fle
//
//  Created by 이정환 on 2/22/24.
//

import UIKit

import RxKakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // TODO: - 임시 로그인해제 로직
        KeychainManager.shared.deleteAccessToken()
        RxKakaoSDK.initSDK(appKey: AppConfigs.API.Kakao.nativeKey)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
