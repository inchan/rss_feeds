//
//  main.swift
//  RssFeed
//
//  Created by inchan kang on 12/24/24.
//

import Foundation

let query: String = "광진구 개발"
let searchQuries = query.toSearchQuries
let old = try XMLLoader(key: query).fromLocalFile()
if let old = old {
    print("old: \(old)")
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
    let publisher = XMLPublisher(rssFeed: merged, key: query)
    do {
        try publisher.publish()
    }
    catch {
        print("publish error: \(error)")
    }
}

