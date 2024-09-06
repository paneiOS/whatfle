//
//  DebugUtils.swift
//  What?fle
//
//  Created by 이정환 on 9/5/24.
//

import Foundation

func logPrint(
    _ items: Any...,
    prefix: String = "[🧑🏻‍💻 LOG]",
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column,
    separator: String = "\n💬 ",
    terminator: String = "\n📍 "
) {
    debugPrint(
        items,
        prefix: prefix,
        file: file,
        function: function,
        line: line,
        column: column,
        separator: separator,
        terminator: terminator
    )
}

func deinitPrint(
    _ items: String = "메모리 해제 되었습니다.",
    prefix: String = "[🙆🏻 DEINIT]",
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column,
    separator: String = "\n💬 ",
    terminator: String = "\n📍 "
) {
    debugPrint(
        items,
        prefix: prefix,
        file: file,
        function: function,
        line: line,
        column: column,
        separator: separator,
        terminator: terminator
    )
}

func errorPrint(
    _ items: Any...,
    prefix: String = "[🚨 ERROR] 에러가 발생하였습니다.",
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column,
    separator: String = "\n💬 ",
    terminator: String = "\n📍 "
) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let itemString = items.map { String(describing: $0) }.joined(separator: separator)
    Swift.print("\(prefix)\(separator)\(itemString)", terminator: "\(terminator)File: \(fileName), Function: \(function), Line: \(line), Column: \(column)\n\n")
    #endif
}

func debugPrint(
    _ items: Any...,
    prefix: String = "[👨🏻‍🔧 DEBUG]",
    file: String = #file,
    function: String = #function,
    line: Int = #line,
    column: Int = #column,
    separator: String = "\n💬 ",
    terminator: String = "\n📍 "
) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let itemString = items.map { String(describing: $0) }.joined(separator: separator)
    Swift.print("\(prefix) \(itemString)", terminator: "\(terminator)File: \(fileName), Function: \(function), Line: \(line), Column: \(column)\n\n")
    #endif
}
