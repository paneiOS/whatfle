//
//  SupabaseService.swift
//  What?fle
//
//  Created by 23 09 on 7/9/24.
//

import Foundation
import Supabase

protocol SupabaseServiceDelegate: AnyObject {
    func signInWithIdToken(provider: OpenIDConnectCredentials.Provider, idToken: String) async throws -> Session
}

final class SupabaseService: SupabaseServiceDelegate {
    var client: SupabaseClient = SupabaseClient(supabaseURL: URL(string: "https://zzfghrhtmemsirwljiei.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6Zmdocmh0bWVtc2lyd2xqaWVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTI0MDM0OTksImV4cCI6MjAyNzk3OTQ5OX0.dVGJFqec15FBUhJFbVfw9utlpGs71S2NZoeTvvEVRMw")

    deinit {
        print("\(self) is being deinit")
    }

    func signInWithIdToken(provider: OpenIDConnectCredentials.Provider, idToken: String) async throws -> Session {
        do {
            let response = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: provider,
                    idToken: idToken
                )
            )
            return response
        } catch {
            throw error
        }
    }
}
