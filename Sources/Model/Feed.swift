//
//  Feed.swift
//  GenFeeds
//
//  Created by inchan kang on 12/11/24.
//

import Foundation


enum RSSType: String {
    case Unknown
    case Naver
    case Google
    case KoreaNewsRSS
    case Integration
}

struct FeedSource: Codable {
    let auther: String
    var link: String? = nil
    
    var toXML: String {
        return if let link = link, !link.isEmpty {
            "<source url=\"\(link.xmlEncoded())\">\(auther.xmlEncoded())</source>"
        }
        else {
            "<source>\(auther.xmlEncoded())</source>"
        }
    }
}

struct Feed: Codable, Equatable, Hashable {
    let title: String
    let link: String
    let desc: String
    let pubDate: Date?
    var source: FeedSource = FeedSource(auther: "Unknown")
    var rssType: RSSType

    enum CodingKeys: String, CodingKey {
        case title
        case link
        case desc = "description"
        case pubDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        link = try container.decode(String.self, forKey: .link)
        desc = try container.decode(String.self, forKey: .desc)
        rssType = .Unknown
        
        let dateString = try container.decode(String.self, forKey: .pubDate)
        if let date = ISO8601DateFormatter.date(from: dateString) {
            pubDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .pubDate, in: container, debugDescription: "Date string does not match format.")
        }
    }
    
    init(title: String, link: String, description: String, pubDate: Date?, source: FeedSource , rssType: RSSType) {
        self.title = title
        self.link = link
        self.desc = description
        self.pubDate = pubDate
        self.source = source
        self.rssType = rssType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine([title, link].map{ $0.hashValue })
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title && lhs.link == rhs.link
    }
}



func filterSimilarFeeds(feeds: [Feed], threshold: Int = 10) -> [Feed] {
    var filteredFeeds = [Feed]()
    
    for feed in feeds {
        let isSimilar = filteredFeeds.contains { existingFeed in
            let distance = levenshtein(feed.title, existingFeed.title)
            return distance < threshold
        }
        
        if !isSimilar {
            filteredFeeds.append(feed)
        }
    }
    
    return filteredFeeds
}

func levenshtein(_ s1: String, _ s2: String) -> Int {
    let empty = [Int](repeating: 0, count: s2.count)
    var last = [Int](0...s2.count)

    for (i, char1) in s1.enumerated() {
        var cur = [i + 1] + empty
        for (j, char2) in s2.enumerated() {
            cur[j + 1] = char1 == char2 ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
        }
        last = cur
    }
    return last.last!
}

extension Collection<Feed> where Element: Equatable {
    func distinct() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
    
    func filterSimilar(threshold: Int = 10) ->  [Feed] {
        var feeds = [Feed]()
        for feed in self {
            let isSimilar = feeds.contains { existingFeed in
                let distance = levenshtein(feed.title, existingFeed.title)
                return distance < threshold
            }
            
            if !isSimilar {
                feeds.append(feed)
            }
        }
        return feeds
    }
}


