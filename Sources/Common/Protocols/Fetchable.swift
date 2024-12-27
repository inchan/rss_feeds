//
//  Fetchable.swift
//  GenFeeds
//
//  Created by inchan kang on 12/11/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
}

protocol Fetchable {
    func fetch() async throws -> RssFeed
    var decoder: DataDecodable { get }
}

protocol HTTPGetFetchable: Fetchable {
    var urlComponents: URLComponents { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
    var httpMethod: String { get }
    var headers: [String: String] { get }
}

extension HTTPGetFetchable {
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalCacheData }
    var timeoutInterval: TimeInterval { 10 }
    var httpMethod: String { "GET" }
    var headers: [String: String] { [:] }
    var decoder: DataDecodable { JSONDataDecoder() }
    
    @MainActor
    func fetch() async throws -> RssFeed {
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData // 캐시 정책 설정
        request.timeoutInterval = 30
        request.allHTTPHeaderFields = ["Content-Type": "application/json"] // 헤더 설정
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 응답 검증
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        do {
            let rssFeed = try decoder.decode(data: data)
            successLog(request: request, rssFeed: rssFeed)
            return rssFeed
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func successLog(request: URLRequest, rssFeed: RssFeed) {
        if let url = request.url?.absoluteString {
            let feedCount = String(format: "%02d", rssFeed.feeds.count)
            print("[REQ] \(rssFeed.title) <\(feedCount)> -> \(url)")
        }
    }
}


extension Data {
    func toString() -> String {
        String(decoding: self, as: UTF8.self)
    }
}
