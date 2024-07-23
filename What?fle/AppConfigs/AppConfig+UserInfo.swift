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
        enum Key {
            static var accessToken: String {
                "Bearer eyJhbGciOiJIUzI1NiIsImtpZCI6IjdvUTl1RGRlN3E5SXNvT2IiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3p6Zmdocmh0bWVtc2lyd2xqaWVpLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiIwNTU0YzczYS1lMTVlLTQ2MDctODVlNy01NDk3NDI1ZmRkN2EiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzIyMzUxODMwLCJpYXQiOjE3MjE3NDcwMzAsImVtYWlsIjoianQyc241OTU5c0Bwcml2YXRlcmVsYXkuYXBwbGVpZC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImFwcGxlIiwicHJvdmlkZXJzIjpbImFwcGxlIl19LCJ1c2VyX21ldGFkYXRhIjp7ImN1c3RvbV9jbGFpbXMiOnsiYXV0aF90aW1lIjoxNzIxNzQ3MDI3LCJpc19wcml2YXRlX2VtYWlsIjp0cnVlfSwiZW1haWwiOiJqdDJzbjU5NTlzQHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJwcm92aWRlcl9pZCI6IjAwMTgxNC4zOGIyYjY2NmE0MWM0NzNjOWE5NDJjYTM3YmY3Yzk1MC4xNjQyIiwic3ViIjoiMDAxODE0LjM4YjJiNjY2YTQxYzQ3M2M5YTk0MmNhMzdiZjdjOTUwLjE2NDIifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJvYXV0aCIsInRpbWVzdGFtcCI6MTcyMTc0NzAzMH1dLCJzZXNzaW9uX2lkIjoiOTM1NDEyMDktZmI5ZS00YTdjLTlmNTAtZDYxYjBmZDBhM2FhIiwiaXNfYW5vbnltb3VzIjpmYWxzZX0.Lg8T19UZNxXq3vdbH7cB3f9hngWDC4hns00Cz9y20qw"
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
