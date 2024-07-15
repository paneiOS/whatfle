//
//  CollectionDataModel.swift
//  What?fle
//
//  Created by JeongHwan Lee on 7/14/24.
//

import UIKit

struct CollectionData {
    let accountID: Int
    let title: String
    let description: String
    let isPublic: Bool
    let hashtags: [String]
    let places: [Int]
    let isActiveCover: Bool
}

struct CollectionDataModel: Codable {
    let accountID: Int
    let title: String
    let description: String
    let isPublic: Bool
    let hashtags: [String]
    let places: [Int]
    let imageURls: [String]
    let isActiveCover: Bool
    
    enum CodingKeys: String, CodingKey {
        case accountID = "accountId"
        case title
        case description
        case isPublic
        case hashtags
        case places
        case imageURls = "imageUrls"
        case isActiveCover
    }

    init(
        data: CollectionData,
        imageURls: [String]
    ) {
        self.accountID = data.accountID
        self.title = data.title
        self.description = data.description
        self.isPublic = data.isPublic
        self.hashtags = data.hashtags
        self.places = data.places
        self.imageURls = imageURls
        self.isActiveCover = data.isActiveCover
    }
}
