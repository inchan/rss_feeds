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
    
    func publish() async throws {
        if rssFeed.feeds.isEmpty {
            guard var oldRssFeed = try XMLLoader(key: key).fromLocalFile() else { return }
            oldRssFeed.updated = Date()
            try await internalPublish(rssFeed: oldRssFeed)
        }
        else {
            try await internalPublish(rssFeed: rssFeed)
        }
    }
    
    private func internalPublish(rssFeed: RssFeed) async throws {
        if #available(macOS 13.0, *) {
            let fileManager = FileManager.default
            let dirPath = Path.writeDirPath()
            print("writeDirPath: \(dirPath)")
            do {
                if (!fileManager.fileExists(atPath: dirPath)) {
                    try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true)
                    print("writeDir created: \(dirPath)")
                }
                let filePath = Path.wirteFilePath(key)
                print("wirteFilePath: \(filePath)")
                let xmlString = rssFeed.toXML
                if let data = xmlString.data(using: .utf8) {
                    let url = URL(filePath: filePath)
                    print("publish url: \(url)")
                    try data.write(to: url)
                    print("publish success: \(filePath)")
                }
            }
            catch {
                print("publish error: \(error)")
                throw error
            }
        }
    }
}

