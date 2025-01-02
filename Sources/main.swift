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

// 비동기 처리용 함수
func fetchFeeds(for keywordGroup: KeywordGroup) async {
    let searchQueries = keywordGroup.keywords.flatMap { $0.toSearchQuries }

    logGroupInfo(keywordGroup, queries: searchQueries)

    let fetchedResults = await fetchAllFeeds(for: searchQueries)

    let feeds = await extractFeeds(from: fetchedResults)
    let mergedFeed = await mergeFeeds(for: keywordGroup, with: feeds, from: fetchedResults)

    await publishFeedIfNeeded(mergedFeed, for: keywordGroup)
}

// 그룹 정보 출력
private func logGroupInfo(_ keywordGroup: KeywordGroup, queries: [String]) {
    print("\n")
    print("group name: \(keywordGroup.name)")
    print("-> Keywords : \n\(queries)")
}

// 모든 피드를 병렬로 가져옴
private func fetchAllFeeds(for queries: [String]) async -> [Result<RssFeed, Error>] {
    await withTaskGroup(of: Result<RssFeed, Error>.self) { group in
        for query in queries {
            group.addTask { await fetchFeed(for: query) }
        }
        return await group.reduce(into: []) { $0.append($1) }
    }
}

// 개별 피드 가져오기
private func fetchFeed(for query: String) async -> Result<RssFeed, Error> {
    let engine = NaverSearch(query: query)
    do {
        let fetched = try await engine.fetch()
        return .success(fetched)
    } catch {
        return .failure(error)
    }
}

// 결과에서 피드 추출 및 필터링
private func extractFeeds(from results: [Result<RssFeed, Error>]) async -> [Feed] {
    await withTaskGroup(of: [Feed].self) { group in
        for result in results {
            group.addTask {
                switch result {
                case .success(let rss): return rss.feeds.distinct().filterSimilar()
                case .failure: return []
                }
            }
        }
        return await group.reduce(into: []) { $0 += $1 }
    }
}

// 피드 병합
private func mergeFeeds(for keywordGroup: KeywordGroup, with feeds: [Feed], from results: [Result<RssFeed, Error>]) async -> RssFeed? {
    await withTaskGroup(of: RssFeed?.self) { group in
        for result in results {
            group.addTask {
                switch result {
                case .success(let rss):
                    return RssFeed(
                        title: keywordGroup.name,
                        desc: keywordGroup.keywords.joined(separator: ", "),
                        link: rss.link,
                        updated: rss.updated,
                        author: "\(RSSType.Integration)",
                        feeds: feeds,
                        type: .Integration
                    )
                case .failure:
                    return nil
                }
            }
        }
        
        // compactMap으로 옵셔널 제거 후 first로 첫 번째 값을 반환
        let merged = await group.reduce(into: [RssFeed]()) { partialResult, rssFeed in
            if let rssFeed = rssFeed {
                partialResult.append(rssFeed)
            }
        }
        return merged.first
    }
}

// 병합된 피드 발행
private func publishFeedIfNeeded(_ rssFeed: RssFeed?, for keywordGroup: KeywordGroup) async {
    guard let rssFeed = rssFeed else { return }

    print("\n")
    print("\(keywordGroup.name) feeds: \(rssFeed.feeds.count)")
    
    let publisher = XMLPublisher(rssFeed: rssFeed, key: keywordGroup.name)
    do {
        try await publisher.publish()
    } catch {
        print("publish error: \(error)")
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
