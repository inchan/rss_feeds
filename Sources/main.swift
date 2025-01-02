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
    KeywordGroup(name: "중곡개발", keywords: [
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

// 비동기 처리용 함수
func fetchFeeds(for keywordGroup: KeywordGroup) async {
    let searchQueries = keywordGroup.keywords.flatMap { $0.toSearchQuries }

    print("\n")
    print("group name: \(keywordGroup.name)")
    print("-> Keywords : \n\(searchQueries)")

//    do {
//        let old = try XMLLoader(key: keywordGroup.name).fromLocalFile()
//        if let old = old {
//            print("old \(old.title): items: \(old.feeds.count)\n")
//        }
//    } catch {
//        print("Failed to load old XML: \(error)")
//    }

    // 비동기 병렬 처리
    let fetchedResults = await withTaskGroup(of: Result<RssFeed, Error>.self) { group in
        for query in searchQueries {
            group.addTask {
                let engine = NaverSearch(query: query)
                do {
                    let fetched = try await engine.fetch()
                    return .success(fetched)
                } catch {
                    return .failure(error)
                }
            }
        }

        var results: [Result<RssFeed, Error>] = []
        for await result in group {
            results.append(result)
        }
        return results
    }

    let feeds = fetchedResults
        .compactMap { result in
            switch result {
            case .success(let rss): return rss.feeds
            case .failure: return []
            }
        }
        .flatMap { $0 }
        .distinct()
        .filterSimilar()

    let merged = fetchedResults
        .compactMap { result in
            switch result {
            case .success(let rss): return rss
            case .failure: return nil
            }
        }
        .first
        .map { rssFeed in
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
        print("\n")
        print("\(keywordGroup.name) feeds: \(merged.feeds.count)")
        let publisher = XMLPublisher(rssFeed: merged, key: keywordGroup.name)
        do {
            try publisher.publish()
        } catch {
            print("publish error: \(error)")
        }
    }
}

let dispatchGroup = DispatchGroup()

func fetchFeedsSync(for keywordGroup: KeywordGroup) {
    dispatchGroup.enter()
    Task {
        await withCheckedContinuation { continuation in
            Task {
                await fetchFeeds(for: keywordGroup)
                continuation.resume()  // 모든 작업 완료 후 그룹에서 나감
            }
        }
        dispatchGroup.leave()  // 여기서 호출 (완전히 끝난 후)
    }
}

for keywordGroup in keywordGroups {
    fetchFeedsSync(for: keywordGroup)
}

// 모든 비동기 작업이 끝날 때까지 대기
dispatchGroup.notify(queue: .main) {
    print("All feeds fetched. Exiting program.")
    exit(0)
}

RunLoop.main.run()
