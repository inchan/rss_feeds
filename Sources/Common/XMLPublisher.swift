//
//  Publisher.swift
//  RssFeed
//
//  Created by inchan kang on 12/23/24.
//

import Foundation
import SwiftSoup

struct XMLPublisher {
    let rssFeed: RssFeed
    let key: String
    
    func publish() throws {
        if rssFeed.feeds.isEmpty {
            guard var oldRssFeed = try XMLLoader(key: key).fromLocalFile() else { return }
            oldRssFeed.updated = Date()
            try internalPublish(rssFeed: oldRssFeed)
        }
        else {
            try internalPublish(rssFeed: rssFeed)
        }
    }
    
    private func internalPublish(rssFeed: RssFeed) throws {
        if #available(macOS 13.0, *) {
            let fileManager = FileManager.default
            let dirPath = Path.writeDirPath()
            do {
                if (!fileManager.fileExists(atPath: dirPath)) {
                    try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true)
                    print("[PUB] created: \(dirPath)")
                }
                let filePath = Path.wirteFilePath(key)
                let xmlString = rssFeed.toXML
                if let data = xmlString.data(using: .utf8) {
                    let url = URL(filePath: filePath)
                    try data.write(to: url)
                    Log("publish success: \(filePath)", tag: "✅", depth: 1)
                }
            }
            catch {
                print("[PUB] error: \(error)")
                throw error
            }
        }
    }
}

