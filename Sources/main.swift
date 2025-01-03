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
    KeywordGroup(name: "중곡동", keywords: [
        "중곡 개발",
        "중곡 재개발",
        "중곡3동 개발",
        "중곡3동 재개발",
        "중곡역 개발",
        "중곡역 재개발"
    ]),
    KeywordGroup(name: "초전도체", keywords: [
        "초전도체",
        "LK-99",
        "신성델타테크",
        "퀸텀에너지연구소"
    ]),
    KeywordGroup(name: "돈나무언니", keywords: [
        "Catherine Wood",
        "캐서린 우드",
        "캐시 우드",
        "cash wood",
    ]),
    KeywordGroup(name: "3기신도시")
]

let maxLength = keywordGroups.flatMap { $0.keywords }.map { $0.count }.max() ?? 0

let dispatchQueue = DispatchQueue(label: "com.feed.fetchQueue")  // 직렬 큐 생성
let dispatchGroup = DispatchGroup()

// 피드 가져오기
func fetchFeeds(for keywordGroup: KeywordGroup) {
    let searchQueries = keywordGroup.keywords.flatMap { $0.toSearchQuries }
    Log(keywordGroup.name, tag: "❤️‍🔥")
    var fetchedResults: [Result<RssFeed, Error>] = []
    for (index, query) in searchQueries.enumerated() {
        let result = fetchFeed(for: query)
        fetchedResults.append(result)
        
        if index < searchQueries.count - 1 {
            // 2초 대기 (마지막 요청 제외)
            Thread.sleep(forTimeInterval: 0.55)
        }
    }
    let feeds = extractFeeds(from: fetchedResults)
    let mergedFeed = mergeFeeds(for: keywordGroup, with: feeds, from: fetchedResults)
    publishFeedIfNeeded(mergedFeed, for: keywordGroup)
}

// 개별 피드 가져오기 (동기)
private func fetchFeed(for query: String) -> Result<RssFeed, Error> {
    let engine = NaverSearch(query: query, maxLength: maxLength)
    do {
        let fetched = try engine.fetch()  // 동기 호출
        return .success(fetched)
    } catch {
        Log("fetch query: \(query) -> \(engine.urlComponents.url?.absoluteString ?? "")", tag: "❌", depth: 1)
        Log("fetch error: \(error)", tag: "❌", depth: 1)
        return .failure(error)
    }
}

// 결과에서 피드 추출 및 필터링
private func extractFeeds(from results: [Result<RssFeed, Error>]) -> [Feed] {
    results.compactMap { result in
        guard case .success(let rss) = result else { return [Feed]() }
        return rss.feeds
    }.flatMap { $0 }.distinct().filterSimilar()
}

// 피드 병합
private func mergeFeeds(for keywordGroup: KeywordGroup, with feeds: [Feed], from results: [Result<RssFeed, Error>]) -> RssFeed? {
    for case .success(let rss) in results {
        return RssFeed(
            title: keywordGroup.name,
            desc: keywordGroup.keywords.joined(separator: ", "),
            link: rss.link,
            updated: rss.updated,
            author: "\(RSSType.Integration)",
            feeds: feeds,
            type: .Integration
        )
    }
    return nil
}

// 병합된 피드 발행
private func publishFeedIfNeeded(_ rssFeed: RssFeed?, for keywordGroup: KeywordGroup) {
    guard let rssFeed = rssFeed else { return }
    
    Log("result: \(rssFeed.feeds.count) feeds", tag: "🧲", depth: 1)
    
    let publisher = XMLPublisher(rssFeed: rssFeed, key: keywordGroup.name)
    do {
        try publisher.publish()
    } catch {
        Log("publish error: \(error)", tag: "❌")
    }
    print("\n")
}

// 동기적으로 피드 가져오기 (DispatchGroup 사용)
func fetchFeedsSync(for keywordGroup: KeywordGroup) {
    dispatchGroup.enter()
    dispatchQueue.sync {
        //print("will enter")
        fetchFeeds(for: keywordGroup)
        //print("will leave")
        dispatchGroup.leave()
    }
}

// 모든 키워드 그룹에 대해 피드 가져오기 (순차적 실행)
for keywordGroup in keywordGroups {
    fetchFeedsSync(for: keywordGroup)
}

dispatchGroup.notify(queue: .main) {
    print("All feeds fetched. Exiting program.")
    RunLoop.main.perform {
        exit(0)
    }
}

// RunLoop 유지
RunLoop.main.run()
