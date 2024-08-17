//
//  AppConfig+UserInfo.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import Foundation

extension AppConfigs {
    enum UserInfo {
        static var accountID: Int {
            93
        }
    }

    enum API {
        enum Supabase {
            static var key: String {
                return (secrets?.value(forKey: "Supabase_API_KEY") as? String) ?? ""
            }

            static var baseURL: String {
                return (secrets?.value(forKey: "SupabaseURL") as? String) ?? ""
            }
        }

        enum Naver {
            static var clientID: String {
                (secrets?.value(forKey: "Naver-Client-ID") as? String) ?? ""
            }

            static var clientSecret: String {
                (secrets?.value(forKey: "Naver-Client-Secret") as? String) ?? ""
            }

            static var searchURL: String {
                (secrets?.value(forKey: "NaverSearchURL") as? String) ?? ""
            }
        }

        enum Kakao {
            static var key: String {
                (secrets?.value(forKey: "Kakao_REST_API_KEY") as? String) ?? ""
            }

            static var searchURL: String {
                "https://dapi.kakao.com/v2/local/"
            }
        }
    }
}
