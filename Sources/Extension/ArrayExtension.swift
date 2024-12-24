//
//  ArrayExtension.swift
//  RssFeed
//
//  Created by inchan kang on 12/23/24.
//

extension Array {
    func asyncMap<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        var results = [T]()
        for element in self {
            let result = try await transform(element)
            results.append(result)
        }
        return results
    }
}
