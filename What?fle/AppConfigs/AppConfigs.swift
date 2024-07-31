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
}
