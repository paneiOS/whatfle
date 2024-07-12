//
//  Date+.swift
//  What?fle
//
//  Created by JeongHwan Lee on 3/31/24.
//

import Foundation

extension Date {
    var formattedYYMMDDWithDot: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter.string(from: self)
    }

    var formattedWithhyphen: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
