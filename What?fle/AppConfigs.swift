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
                "Bearer eyJhbGciOiJIUzI1NiIsImtpZCI6IjdvUTl1RGRlN3E5SXNvT2IiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzIwODU2OTQyLCJpYXQiOjE3MjAyNTIxNDIsImlzcyI6Imh0dHBzOi8venpmZ2hyaHRtZW1zaXJ3bGppZWkuc3VwYWJhc2UuY28vYXV0aC92MSIsInN1YiI6IjA1NTRjNzNhLWUxNWUtNDYwNy04NWU3LTU0OTc0MjVmZGQ3YSIsImVtYWlsIjoianQyc241OTU5c0Bwcml2YXRlcmVsYXkuYXBwbGVpZC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImFwcGxlIiwicHJvdmlkZXJzIjpbImFwcGxlIl19LCJ1c2VyX21ldGFkYXRhIjp7ImN1c3RvbV9jbGFpbXMiOnsiYXV0aF90aW1lIjoxNzIwMjUyMTM5LCJpc19wcml2YXRlX2VtYWlsIjp0cnVlfSwiZW1haWwiOiJqdDJzbjU5NTlzQHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJwcm92aWRlcl9pZCI6IjAwMTgxNC4zOGIyYjY2NmE0MWM0NzNjOWE5NDJjYTM3YmY3Yzk1MC4xNjQyIiwic3ViIjoiMDAxODE0LjM4YjJiNjY2YTQxYzQ3M2M5YTk0MmNhMzdiZjdjOTUwLjE2NDIifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJvYXV0aCIsInRpbWVzdGFtcCI6MTcyMDI1MjE0Mn1dLCJzZXNzaW9uX2lkIjoiZTZkYjQwMjctOTk2Yi00YTRjLWFmZjAtYjdkMDE1NWNiNGViIiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.9iARMt28wE_puLuq8IqjVPNbZbEnUoz5EZz3i41gIzQ"
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
