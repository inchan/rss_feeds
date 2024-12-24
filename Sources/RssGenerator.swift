//
//  RssGenerator.swift
//  MyPackage
//
//  Created by inchan kang on 12/24/24.
//

import Foundation

let inputPath = "./Feeds/input.xml"
let outputPath = "./Feeds/output.xml"

func parseAndRebuildRSS() {
    guard let data = FileManager.default.contents(atPath: inputPath) else {
        print("Failed to read input XML")
        return
    }

    let parser = XMLParser(data: data)
    let rssHandler = RSSParserHandler()
    parser.delegate = rssHandler
    
    if parser.parse() {
        print("Successfully parsed RSS.")
        rebuildRSS(with: rssHandler.items)
    } else {
        print("Failed to parse RSS.")
    }
}

func rebuildRSS(with items: [RSSItem]) {
    var xmlString = """
    <?xml version="1.0" encoding="UTF-8" ?>
    <rss version="2.0">
    <channel>
    <title>My Custom RSS Feed</title>
    """

    for item in items {
        xmlString += """
        <item>
        <title>\(item.title)</title>
        <link>\(item.link)</link>
        <description>\(item.description)</description>
        </item>
        """
    }

    xmlString += """
    </channel>
    </rss>
    """

    try? xmlString.write(toFile: outputPath, atomically: true, encoding: .utf8)
    print("RSS feed successfully rebuilt at \(outputPath)")
}

struct RSSItem {
    let title: String
    let link: String
    let description: String
}

class RSSParserHandler: NSObject, XMLParserDelegate {
    var items: [RSSItem] = []
    var currentElement = ""
    var currentTitle = ""
    var currentLink = ""
    var currentDescription = ""

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            currentLink += string
        case "description":
            currentDescription += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName: String?) {
        if elementName == "item" {
            let item = RSSItem(title: currentTitle, link: currentLink, description: currentDescription)
            items.append(item)
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
        }
    }
}


