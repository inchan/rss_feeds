//
//  LocalPath.swift
//  RssFeed
//
//  Created by inchan kang on 12/23/24.
//

import Foundation

struct Path {
    static func writeDirPath() -> String {
        if (FileManager.default.fileExists(atPath: "/Users/inchan/Desktop/Publish")) {
            return "/Users/inchan/Desktop/Publish"
        }
        else {
            return "./Feeds"
        }
    }
    static func wirteFilePath(_ fileName: String) -> String {
        return Path.writeDirPath().appending("/\(fileName).xml")
    }
}
