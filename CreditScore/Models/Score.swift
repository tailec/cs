//
//  Score.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import Foundation

// this type represents domain and platform entities (like realm/core data/networking models)
// it'd be nice to have different types of models to enforce modularity
struct Score {
    let score: Int // I'm assuming score is always present in the response
    
    enum CodingKeys: String, CodingKey {
        case creditReportInfo
    }
    
    enum CreditReportInfoKeys: String, CodingKey {
        case score
    }
}

// normally I'd implement Parseable protocol so it's easy to swap encoding/decoding to SwiftyJson or something else if needed but Codable should work for many years :)
extension Score: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let creditReportInfo = try container.nestedContainer(keyedBy: CreditReportInfoKeys.self, forKey: .creditReportInfo)
        self.score = try creditReportInfo.decode(Int.self, forKey: .score)
    }
}

extension Score: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var creditReportInfo = container.nestedContainer(keyedBy: CreditReportInfoKeys.self,
                                                         forKey: .creditReportInfo)
        try creditReportInfo.encode(score, forKey: .score)
    }
}

extension Score: Identifiable {
    var uid: String {
        return Constants.uid
    }
}

extension Score {
    static let sharedUID = Constants.uid
}

fileprivate enum Constants {
    static var uid: String {
        return "123123" // I haven't seen any ids in API response so I'm just hardcoding for exercise purposes. I always get same API response
    }
}
