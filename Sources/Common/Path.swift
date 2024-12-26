//
//  LocalPath.swift
//  RssFeed
//
//  Created by inchan kang on 12/23/24.
//

import Foundation

struct Path {
    static func writeDirPath() -> String {
#if DEBUG
        return (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
            .first?.appending("/Publish")) ?? ""
#else
        return "./Feeds"
#endif
    }
    static func wirteFilePath(_ fileName: String) -> String {
        return Path.writeDirPath().appending("/\(fileName).xml")
    }
}
