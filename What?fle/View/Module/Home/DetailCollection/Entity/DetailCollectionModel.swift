//
//  DetailCollectionModel.swift
//  What?fle
//
//  Created by 이정환 on 8/7/24.
//

import Foundation

struct DetailCollectionModel: Decodable {
    let id: Int
    let accountID: Int
    let title: String
    let description: String
    let createdAt: String
    let updatedAt: String?
    let deletedAt: String?
    let isPublic: Bool
    let imageURLs: [String]
    let isActiveCover: Bool
    let hashtags: [Hashtag]
    let places: [PlaceRegistration]

    enum CodingKeys: String, CodingKey {
        case id
        case accountID = "accountId"
        case title
        case description
        case createdAt
        case updatedAt
        case deletedAt
        case isPublic
        case imageURLs = "imageUrls"
        case isActiveCover
        case hashtags
        case places
    }

    struct Hashtag: Decodable {
        let id: Int
        let hashtagName: String
    }
}
