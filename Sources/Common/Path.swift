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
        let dir = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
            .first?.appending("/Publish")) ?? ""
        print("writeDirPath: \(dir)")
        return dir
#else
        print("writeDirPath: ./Feeds")
        return "./Feeds"
#endif
    }
    static func wirteFilePath(_ fileName: String) -> String {
        return Path.writeDirPath().appending("/\(fileName).xml")
    }
}
