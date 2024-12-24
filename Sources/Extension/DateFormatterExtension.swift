//
//  DateFormatterExtension.swift
//  GenFeeds
//
//  Created by inchan kang on 12/23/24.
//

import Foundation

let ISO8601DateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z" // 예: "Tue, 14 Dec 2021 10:00:00 +0000"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

let DefaultFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

