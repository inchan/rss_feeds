//
//  DateExtension.swift
//  GenFeeds
//
//  Created by inchan kang on 12/23/24.
//
import Foundation

extension Date {
    func toISO8601String() -> String {
        return ISO8601DateFormatter.string(from: self)
    }
    
    
    static func fromISO8601String(_ string: String) -> Date? {
        return ISO8601DateFormatter.date(from: string)
    }
    
    static func fromString(_ string: String) -> Date? {
        return DefaultFormatter.date(from: string)
    }

}
