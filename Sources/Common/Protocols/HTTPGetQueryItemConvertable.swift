//
//  QueryItemConvertable.swift
//  GenFeeds
//
//  Created by inchan kang on 12/12/24.
//

import Foundation

protocol HTTPGetQueryItemConvertable {
    var rawValue: String { get }
    var queryName: String { get }
    var queryItem: URLQueryItem { get }
}

extension HTTPGetQueryItemConvertable {
    var queryItem: URLQueryItem {
        URLQueryItem(name: queryName, value: rawValue)
    }
}

