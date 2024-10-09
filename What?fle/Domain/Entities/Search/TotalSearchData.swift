//
//  TotalSearchData.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import Foundation

struct TotalSearchData: Decodable {
    let collectionContents: CollectionContent
    let hashtagContents: HashTag

    struct CollectionContent: Decodable {
        let count: Int
        let collections: [Collection]?

        enum CodingKeys: String, CodingKey {
            case count = "counts"
            case collections
        }

        struct Collection: Decodable {
            let id: Int
            let accountID: Int
            let title: String
            let description: String
            let isPublic: Bool
            let imageURLs: [String]
            let isActiveCover: Bool
            let hashtags: [RecommendHashTagModel]
            let places: [PlaceRegistration]

            enum CodingKeys: String, CodingKey {
                case id
                case accountID = "accountId"
                case title
                case description
                case isPublic
                case imageURLs = "imageUrls"
                case isActiveCover
                case hashtags
                case places
            }
        }
    }

    struct HashTag: Decodable {
        let count: Int
        let hashtags: [RecommendHashTagModel]?

        enum CodingKeys: String, CodingKey {
            case count = "counts"
            case hashtags
        }
    }
}
