//
//  DebugUtils.swift
//  What?fle
//
//  Created by 이정환 on 9/5/24.
//

import Foundation

func logPrint(
    _ items: Any...,
    prefix: String = "[🧑🏻‍💻 DEBUG]",
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column,
    separator: String = "\n- ",
    terminator: String = "\n"
) {
    debugPrint(items, prefix: "[🧑🏻‍💻 DEBUG]")
}

func errorPrint(
    _ items: Any...,
    prefix: String = "[🧑🏻‍💻 DEBUG]",
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column,
    separator: String = "\n- ",
    terminator: String = "\n"
) {
    debugPrint(items, prefix: "[🚨 ERROR]")
}

func debugPrint(
    _ items: Any...,
    prefix: String = "[🧑🏻‍💻 DEBUG]",
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column,
    separator: String = "\n💬 ",
    terminator: String = "\n📍 "
) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let itemString = items.map { String(describing: $0) }.joined()
        .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        .replacingOccurrences(of: "\"", with: "")
        .components(separatedBy: ", ")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .joined(separator: separator)
        

    Swift.print("\(prefix) \(itemString)", terminator: "\(terminator)[File: \(fileName), Function: \(function), Line: \(line), Column: \(column)]\n\n")
    #endif
}
