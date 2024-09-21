//
//  UserDefaultsManager.swift
//  What?fle
//
//  Created by 이정환 on 3/21/24.
//

import Foundation

struct UserDefaultsManager {
    static let searchHistory = "searchHistory"

    static func recentSearchSave(searchText: String) {
        var history = UserDefaults.standard.array(forKey: searchHistory) as? [String] ?? []
        if let firstIndex = history.firstIndex(of: searchText) {
            history.remove(at: firstIndex)
            history.insert(searchText, at: 0)
        } else {
            history.insert(searchText, at: 0)
            if history.count >= 10 {
                history.remove(at: history.count - 1)
            }
        }
        UserDefaults.standard.set(history, forKey: searchHistory)
    }

    static func recentSearchRemove(index: Int) -> [String] {
        var history = UserDefaults.standard.array(forKey: searchHistory) as? [String] ?? []
        if history.count - 1 >= index {
            history.remove(at: index)
        }
        UserDefaults.standard.set(history, forKey: searchHistory)
        return history
    }

    static func recentSearchAllRemove() {
        UserDefaults.standard.set([], forKey: searchHistory)
    }

    static func latestSearchLoad() -> String {
        if let history = UserDefaults.standard.array(forKey: searchHistory) as? [String] {
            return history.first ?? ""
        }
        return ""
    }

    static func recentSearchLoad() -> [String] {
        return UserDefaults.standard.array(forKey: searchHistory) as? [String] ?? []
    }
}
