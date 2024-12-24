//
//  FetchDataDecodable.swift
//  GenFeeds
//
//  Created by inchan kang on 12/12/24.
//

import Foundation

protocol DataDecodable {
    func decode(data: Data) throws -> RssFeed
}
