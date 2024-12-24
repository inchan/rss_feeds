//
//  LocalPath.swift
//  RssFeed
//
//  Created by inchan kang on 12/23/24.
//

import Foundation

struct Path {
    static func writeDirPath() -> String {
#if !DEBUG
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


func getProjectRoot() -> String? {
    let filePath = #file
    let fileURL = URL(fileURLWithPath: filePath)
    
    // 프로젝트 루트까지의 경로를 구성
    var directory = fileURL.deletingLastPathComponent()
    
    // 일반적으로 소스 파일은 프로젝트 디렉토리 내 특정 폴더에 위치하므로 상위 디렉토리 반복
    while !directory.pathComponents.isEmpty {
        if directory.lastPathComponent == "Sources" || directory.lastPathComponent == "MyApp" {
            return directory.deletingLastPathComponent().path
        }
        directory = directory.deletingLastPathComponent()
    }
    return nil
}

