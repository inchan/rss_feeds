//
//  main.swift
//  RssFeed
//
//  Created by inchan kang on 12/24/24.
//

import Foundation

struct KeywordGroup {
    let name: String
    let keywords: [String]
    
    init(name: String, keywords: [String] = []) {
        self.name = name
        if (keywords.isEmpty) {
            self.keywords = [name]
        }
        else {
            self.keywords = keywords
        }
    }
}

let keywordGroups: [KeywordGroup] = [
//    KeywordGroup(name: "중곡개발", keywords: [
//        "중곡3동 개발",
//        "중곡3동 재개발",
//        "중곡역 개발",
//        "중곡역 재개발"
//    ]),
//    KeywordGroup(name: "초전도체", keywords: [
//        "초전도체",
//        "LK-99",
//        "신성델타테크",
//        "퀸텀에너지연구소"
//    ]),
    KeywordGroup(name: "돈나무언니", keywords: [
        "Catherine Wood",
        "캐서린 우드",
        "캐시 우드",
        "cash wood",
    ]),
//    KeywordGroup(name: "3기신도시")
]

let quries = keywordGroups.map({ $0.keywords }).flatMap({ $0 })

for keywordGroup in keywordGroups {
    let searchQuries =  keywordGroup.keywords.map{ $0.toSearchQuries }.flatMap{ $0 }
    print("\n")
    print("group name: \(keywordGroup.name)")
    print("-> Keywords : \n\(searchQuries)")

    let old = try XMLLoader(key: keywordGroup.name).fromLocalFile()
    if let old = old {
        print("old \(old.title): items: \(old.feeds.count)\n")
    }

    let engines = searchQuries.map { [NaverSearch(query: $0)] }.flatMap{ $0 }
    let fetched = await engines.asyncMap { engine -> Result<RssFeed, Error> in
        do {
            let fetched = try await engine.fetch()
            return Result.success(fetched)
        } catch {
            return Result.failure(error)
        }
    }

    let feeds = fetched
        .reduce([Feed]()) { partialResult, r in
            switch r {
            case .success(let rss): partialResult + rss.feeds
            case .failure(_): partialResult
            }
        }
        .distinct()
        .filterSimilar()

    let merged = fetched
        .compactMap { r in
            switch r {
            case .success(let rss): rss
            case .failure(_): nil
            }
        }
        .first
        .map{ rssFeed in
            RssFeed(
                title: rssFeed.title,
                desc: rssFeed.desc,
                link: rssFeed.link,
                updated: rssFeed.updated,
                author: "\(RSSType.Integration)",
                feeds: feeds,
                type: .Integration
            )
        }

    if let merged = merged {
        let publisher = XMLPublisher(rssFeed: merged, key: keywordGroup.name)
        do {
            try publisher.publish()
        }
        catch {
            print("publish error: \(error)")
        }
    }
}
