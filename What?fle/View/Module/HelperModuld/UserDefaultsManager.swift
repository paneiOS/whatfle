//
//  UserDefaultsManager.swift
//  What?fle
//
//  Created by 이정환 on 3/21/24.
//

import Foundation

struct UserDefaultsManager {
    enum HistoryType: String {
        case home
        case location
    }

    static func recentSearchSave(type: HistoryType, searchText: String) {
        var history = UserDefaults.standard.array(forKey: type.rawValue) as? [String] ?? []
        if let firstIndex = history.firstIndex(of: searchText) {
            history.remove(at: firstIndex)
            history.insert(searchText, at: 0)
        } else {
            history.insert(searchText, at: 0)
            if history.count >= 10 {
                history.remove(at: history.count - 1)
            }
        }
        UserDefaults.standard.set(history, forKey: type.rawValue)
    }

    static func recentSearchRemove(type: HistoryType, index: Int) -> [String] {
        var history = UserDefaults.standard.array(forKey: type.rawValue) as? [String] ?? []
        if history.count - 1 >= index {
            history.remove(at: index)
        }
        UserDefaults.standard.set(history, forKey: type.rawValue)
        return history
    }

    static func historyAllRemove(type: HistoryType) {
        UserDefaults.standard.set([], forKey: type.rawValue)
    }

    static func latestSearchLoad(type: HistoryType) -> String {
        if let history = UserDefaults.standard.array(forKey: type.rawValue) as? [String] {
            return history.first ?? ""
        }
        return ""
    }

    static func recentSearchLoad(type: HistoryType) -> [String] {
        return UserDefaults.standard.array(forKey: type.rawValue) as? [String] ?? []
    }
}
