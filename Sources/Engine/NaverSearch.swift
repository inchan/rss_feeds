//
//  NaverSearch.swift
//  GenFeeds
//
//  Created by inchan kang on 12/11/24.
//

import Foundation
import SwiftSoup

struct NaverSearch: Engine, HTTPGetFetchable {
    var query: String
    var maxLength: Int
    let `where` = Query.Where.news
    let page = Query.Page.first
    let sort = Query.Sort.relevance
    let period = Query.Period.oneDay
    
    var urlComponents: URLComponents {
        let baseURL = "https://search.naver.com/search.naver"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            `where`.queryItem,
            page.queryItem,
            sort.queryItem,
            period.queryItem
        ]
        return components
    }
    
    var decoder: any DataDecodable { NaverDataDecoder(link: urlComponents.url?.absoluteString ?? "") }
}

extension NaverSearch {
    
    enum Query {
        
        enum Where: String, HTTPGetQueryItemConvertable {
            
            case news = "news"
            case blog = "blog"
            case cafearticle = "cafearticle"
            case book = "book"
            case encyclopedia = "ency"
            case movie = "movie"
            
            var queryName: String { "where" }
        }
        
        enum Page: String, HTTPGetQueryItemConvertable {
            case first = "1"
            case second = "2"
            case third = "3"
            case tenth = "10"
            case twentyFirst = "21"
            
            var queryName: String { "start" }
        }
        
        enum Sort: String, HTTPGetQueryItemConvertable {
            case relevance = "0"  // 정확도순
            case dateDesc = "1"   // 날짜순 (최신순)
            
            var queryName: String { "sort" }
        }
        
        enum Period: String, HTTPGetQueryItemConvertable {
            case oneDay = "1"     // 1일
            case oneWeek = "7"    // 1주일
            case oneMonth = "30"  // 1개월
            case threeMonths = "90" // 3개월
            case sixMonths = "180"  // 6개월
            case oneYear = "365"    // 1년
            
            var queryName: String { "pd" }
        }
    }
}
