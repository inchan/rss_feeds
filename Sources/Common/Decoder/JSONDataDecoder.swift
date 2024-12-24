//
//  DefaultDecoder.swift
//  GenFeeds
//
//  Created by inchan kang on 12/12/24.
//

import Foundation

struct JSONDataDecoder: DataDecodable {
    
    func decode(data: Data) throws -> RssFeed{
        return try JSONDecoder().decode(RssFeed.self, from: data)
    }
}
