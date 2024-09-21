//
//  AppConfigs.swift
//  What?fle
//
//  Created by 이정환 on 2/28/24.
//

import Foundation

enum AppConfigs {
    static var secrets: NSDictionary? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) else {
            print("⚠️ 'Secrets.plist' not found or is not accessible.")
            return nil
        }
        return dictionary
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
            static var restKey: String {
                (secrets?.value(forKey: "Kakao_REST_API_KEY") as? String) ?? ""
            }

            static var nativeKey: String {
                (secrets?.value(forKey: "Kakao_NATIVE_APP_KEY") as? String) ?? ""
            }

            static var searchURL: String {
                "https://dapi.kakao.com/v2/local/"
            }
        }
    }

}
