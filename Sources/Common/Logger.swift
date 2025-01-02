//
//  Logger.swift
//  RssFeed
//
//  Created by inchan kang on 1/2/25.
//


func Log(_ s: String, tag: String = "", depth: Int = 0) {
    let indentation = String(repeating: "\t", count: depth)
    print("\(indentation) \(tag.uppercased()) \(s)")
}
