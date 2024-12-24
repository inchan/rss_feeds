//
//  RssFeedParse.swift
//  RssFeed
//
//  Created by inchan kang on 12/23/24.
//

import Foundation
import SwiftSoup

class XMLLoader {
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    func fromLocalFile() throws -> RssFeed? {
        if #available(macOS 13.0, *) {
            let fileManager = FileManager.default
            let filePath = Path.wirteFilePath(key)
            if (fileManager.fileExists(atPath: filePath)) {
                let data = try Data(contentsOf: URL(filePath: filePath))
                let xmlString = String(data: data, encoding: .utf8)!
                do {
                    // XML 파싱 시작
                    let doc: Document = try SwiftSoup.parse(xmlString, "", Parser.xmlParser())
                    
                    // 루트 <rss> 요소 접근
                    if let channel = try doc.select("channel").first() {
                        let title = try channel.select("title").first()?.text().xmlDecoded() ?? ""
                        let link = try channel.select("link").first()?.text().xmlDecoded() ?? ""
                        let description = try channel.select("description").first()?.text().xmlDecoded() ?? ""
                        let lastBuildDate = try channel.select("lastBuildDate").text().xmlDecoded()
                        let author = try channel.select("author").first()?.text().xmlDecoded() ?? ""
                        let type = RSSType(rawValue: author) ?? .Unknown
                        
                        let feeds = try convertToFeeds(elements: channel.select("item"), type: type)
                    
                        return RssFeed(
                            title: title,
                            desc: description,
                            link: link,
                            updated: Date.fromString(lastBuildDate) ?? .now,
                            author: author,
                            feeds: feeds,
                            type: type
                        )
                    }
                    
                } catch {
                    print("Error parsing XML: \(error)")
                    throw error
                }
            }
        }
        return nil
    }
    
    func convertToFeeds(elements: Elements, type: RSSType) throws -> [Feed] {
        try elements.map { element in
            let title = try element.select("title").text().xmlDecoded()
            let description = try element.select("description").text().xmlDecoded()
            let link = try element.select("link").text().xmlDecoded()
            let pubDate = try element.select("pubDate").text().xmlDecoded()
            let source = try element.select("source")
            let auther = try source.text().xmlDecoded()
            let souceLink = try? source.attr("url").xmlDecoded()
            
            return Feed(
                title: title,
                link: link,
                description: description,
                pubDate: Date.fromISO8601String(pubDate),
                source: .init(auther: auther, link: souceLink),
                rssType: type
            )
        }
    }
}
