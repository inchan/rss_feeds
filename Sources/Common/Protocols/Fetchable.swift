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
    var query: String { get set }
    var maxLength: Int { get }
}

protocol HTTPGetFetchable: Fetchable {
    var urlComponents: URLComponents { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
    var httpMethod: String { get }
    var headers: [String: String] { get }
}

extension HTTPGetFetchable {
    var cachePolicy: NSURLRequest.CachePolicy { .reloadIgnoringLocalCacheData }
    var timeoutInterval: TimeInterval { 30 }
    var httpMethod: String { "GET" }
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var decoder: DataDecodable { JSONDataDecoder() }
    
    func fetch() throws -> RssFeed {
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        request.allHTTPHeaderFields = headers // 헤더 설정
        
        // 세마포어 생성 (초기값 0)
        let semaphore = DispatchSemaphore(value: 0)
        
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        // 비동기 요청을 동기적으로 처리
        URLSession.shared.dataTask(with: request) { (responseData, urlResponse, responseError) in
            data = responseData
            response = urlResponse
            error = responseError
            semaphore.signal()  // 요청 완료 후 세마포어 신호
        }.resume()
        
        // 요청이 완료될 때까지 대기 (최대 30초)
        _ = semaphore.wait(timeout: .now() + timeoutInterval + 1)

        guard error == nil else {
            throw NetworkError.invalidResponse
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        guard let d = data, d.isEmpty == false else {
            throw NetworkError.noData
        }
        
        do {
            let rssFeed = try decoder.decode(data: d)
            successLog(request: request, rssFeed: rssFeed)
            return rssFeed
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func successLog(request: URLRequest, rssFeed: RssFeed) {
        if let url = request.url?.absoluteString {
            let feedCount = String(format: "%02d", rssFeed.feeds.count)
            var str = "[\(query)]"
            while str.count < (maxLength) {
                str += " "
            }
            str += ": \(url) -> \(feedCount) feeds"
            Log(str, tag: "🚀", depth: 1)
        }
    }
}


extension Data {
    func toString() -> String {
        String(decoding: self, as: UTF8.self)
    }
}
