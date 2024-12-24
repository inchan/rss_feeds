//
//  RSS.swift
//  GenFeeds
//
//  Created by inchan kang on 12/12/24.
//

import Foundation

struct RssFeed: Codable {
    let title: String
    let desc: String
    let link: String
    var updated: Date
    let author: String
    let feeds: [Feed]
    let type: RSSType
    
    enum CodingKeys: String, CodingKey {
        case title
        case desc
        case link
        case updated
        case author
        case feeds
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        desc = try container.decode(String.self, forKey: .desc)
        link = try container.decode(String.self, forKey: .link)
    
        let dateString = try container.decode(String.self, forKey: .updated)
        if let date = ISO8601DateFormatter.date(from: dateString) {
            updated = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .updated, in: container, debugDescription: "Date string does not match format.")
        }

        author = try container.decode(String.self, forKey: .author)
        feeds = try container.decode([Feed].self, forKey: .feeds)
        type = .Unknown
    }
    
    
    init(title: String, desc: String, link: String, updated: Date, author: String, feeds: [Feed], type: RSSType) {
        self.title = title
        self.desc = desc
        self.link = link
        self.updated = updated
        self.author = author
        self.feeds = feeds
        self.type = type
    }
    
}


extension RssFeed: CustomStringConvertible, CustomDebugStringConvertible {
    
    var toXML: String {
"""
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
    <channel>
        <title>\(title.xmlEncoded())</title>
        <link>\(link.xmlEncoded())</link>
        <description>\(desc.xmlEncoded())</description>
        <lastBuildDate>\(updated)</lastBuildDate>
        <author>\(author.xmlEncoded())</author>
\(feeds.map({ $0.toXML }).joined(separator: "\n"))
    </channel>
</rss>
"""
    }
    
    var description: String {
        debugDescription
    }
    
    var debugDescription: String {
        toXML.replacingOccurrences(of: "\\n", with: "\n")
    }
}

extension Feed: CustomStringConvertible, CustomDebugStringConvertible {
    var toXML: String {
"""
        <item>
            <title>\(title.xmlEncoded())</title>
            <link>\(link.xmlEncoded())</link>
            <description>\(desc.xmlEncoded())</description>
            <pubDate>\(pubDate?.toISO8601String() ?? "")</pubDate>
            \(source.toXML)
        </item>
"""
    }
    
    var description: String {
        debugDescription
    }
    
    var debugDescription: String {
        toXML.replacingOccurrences(of: "\\n", with: "\n")
    }
}
