//
//  NaverDecoder.swift
//  GenFeeds
//
//  Created by inchan kang on 12/11/24.
//

import Foundation
import SwiftSoup

struct NaverDataDecoder: DataDecodable {
    
    let link: String
    
    func decode(data: Data) throws -> RssFeed {
        guard let html = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        let document = try SwiftSoup.parse(html)
        let title = try document.title()
        let articles = try document.select(".news_area")
        
        let feeds = try articles.map { article in
            let title = try extractElementText(element: article, selector: "a.news_tit")
            let description = try extractElementText(element: article, selector: "div.news_dsc a.api_txt_lines")
            let link = try extractElementAttribute(element: article, selector: "a.news_tit", attribute: "href")
            let author = try extractElementText(element: article, selector: "div.info_group a.info.press", defaultValue: "unknown")
            var sourceLink: String? = nil
            if let sourceLinkElement = try? document.select(".info.press").attr("href"), !sourceLinkElement.isEmpty {
                sourceLink = sourceLinkElement
            }
            let source = FeedSource(auther: author.isEmpty ? "Unknown" : author, link: sourceLink)
            let relativeTime = try extractElementText(element: article, selector: "div.info_group span.info")
            let pubDate = relativeTime.toRelativeTimeDate()
            let feed = Feed(title: title, link: link, description: description, pubDate: pubDate, source: source, rssType: .Naver)
            return feed
        }
        

        return RssFeed(
            title: title,
            desc: "Naver News Feed",
            link: link,
            updated: feeds
                .compactMap({ $0.pubDate })
                .sorted(by: { $0.timeIntervalSince1970 < $1.timeIntervalSince1970 })
                .first ?? Date(),
            author: "Naver",
            feeds: feeds,
            type: .Naver
        )
    }

    private func extractElementText(element: Element, selector: String, defaultValue: String = "") throws -> String {
        return try element.select(selector).first()?.text() ?? defaultValue
    }

    private func extractElementAttribute(element: Element, selector: String, attribute: String, defaultValue: String = "") throws -> String {
        return try element.select(selector).first()?.attr(attribute) ?? defaultValue
    }

}
