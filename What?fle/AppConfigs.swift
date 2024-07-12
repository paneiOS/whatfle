//
//  AppConfigs.swift
//  What?fle
//
//  Created by 이정환 on 2/28/24.
//

import Foundation

enum AppConfigs {
    private static var secrets: NSDictionary? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) else {
            print("⚠️ 'Secrets.plist' not found or is not accessible.")
            return nil
        }
        return dictionary
    }
}

extension AppConfigs {
    enum UserInfo {
        static var accountID: Int {
            1
        }
    }

    enum API {
        enum Key {
            static var accessToken: String {
                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6Zmdocmh0bWVtc2lyd2xqaWVpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxMjQwMzQ5OSwiZXhwIjoyMDI3OTc5NDk5fQ.wPl_q3dqNsMpnQvX4dvqNnsFXEOJskr02Xt8JUCh5L0"
            }

            enum Naver {
                static var clientID: String {
                    (secrets?.value(forKey: "Naver-Client-ID") as? String) ?? ""
                }

                static var clientSecret: String {
                    (secrets?.value(forKey: "Naver-Client-Secret") as? String) ?? ""
                }
            }

            enum Kakao {
                static var kakaoRESTAPIKey: String {
                    (secrets?.value(forKey: "Kakao_REST_API_KEY") as? String) ?? ""
                }
            }
        }

        enum BaseURL {
            static var dev: String {
                "https://zzfghrhtmemsirwljiei.supabase.co/functions/v1/whatfle"
            }

            enum Naver {
                static var search: String {
                    (secrets?.value(forKey: "NaverSearchURL") as? String) ?? ""
                }
            }

            enum Kakao {
                static var search: String {
                    "https://dapi.kakao.com/v2/local/"
                }
            }
        }
    }
}
