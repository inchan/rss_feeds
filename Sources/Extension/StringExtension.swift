//
//  StringExtension.swift
//  GenFeeds
//
//  Created by inchan kang on 12/23/24.
//

import Foundation

extension String {
    
    func toRelativeTimeDate() -> Date? {
        let now = Date()
        let calendar = Calendar.current

        // 상대 시간 패턴과 변환 단위 매핑
        let timeUnits: [(pattern: String, component: Calendar.Component)] = [
            ("초 전", .second),
            ("분 전", .minute),
            ("시간 전", .hour),
            ("일 전", .day),
            ("주 전", .weekOfYear),
            ("개월 전", .month),
            ("년 전", .year)
        ]

        // 패턴 매칭
        for (pattern, component) in timeUnits {
            if contains(pattern),
               let value = Int(replacingOccurrences(of: pattern, with: "").trimmingCharacters(in: .whitespaces)) {
                let calculatedDate = calendar.date(byAdding: component, value: -value, to: now)
                // 오늘이면 시간과 분까지 포함, 그렇지 않으면 초와 분을 제거
                if let date = calculatedDate {
                    if calendar.isDateInToday(date) {
                        return date
                    } else {
                        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
                        return calendar.date(from: components)
                    }
                }
            }
        }
        return nil
    }
    
    
    var toSearchQuries: [String] {
        let split = self.split(separator: " ")
        var searchQuries = split.map { string in
            split.map({ $0 == string ? "\"\($0)\"" : $0}).joined(separator: " ")
        }
        searchQuries.insert(self, at: 0)
        return searchQuries
    }
    
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    func xmlEncoded() -> String {
        return self
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&apos;")
    }

    func xmlDecoded() -> String {
        return self
        .replacingOccurrences(of: "&amp;", with: "&")
        .replacingOccurrences(of: "lt;", with: "<")
        .replacingOccurrences(of: "&gt;", with: ">")
        .replacingOccurrences(of: "&quot;", with: "\"")
        .replacingOccurrences(of: "&apos;", with: "'&apos;'")
    }
}
