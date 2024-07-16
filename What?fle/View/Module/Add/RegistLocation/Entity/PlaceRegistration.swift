//
//  PlaceRegistration.swift
//  What?fle
//
//  Created by 이정환 on 5/10/24.
//

import UIKit

struct PlaceRegistration: Decodable {
    var id: Int?
    var accountID: Int
    var description: String
    var visitDate: String
    var placeName: String
    var address: String
    var roadAddress: String
    var images: [UIImage]
    var imageURLs: [String]?
    var latitude: Double
    var longitude: Double
    var categoryGroupCode: CategoryGroupCode

    var isEmptyImageURLs: Bool {
        self.imageURLs?.isEmpty ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case visitDate
        case placeName
        case address
        case roadAddress
        case accountID = "accountId"
        case imageURLs = "imageUrls"
        case categoryGroupCode
        case longitude = "longitude"
        case latitude = "latitude"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        accountID = try container.decode(Int.self, forKey: .accountID)
        description = try container.decode(String.self, forKey: .description)
        visitDate = try container.decode(String.self, forKey: .visitDate)
        placeName = try container.decode(String.self, forKey: .placeName)
        address = try container.decode(String.self, forKey: .address)
        roadAddress = try container.decode(String.self, forKey: .roadAddress)
        imageURLs = try container.decodeIfPresent([String].self, forKey: .imageURLs)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        categoryGroupCode = try container.decode(CategoryGroupCode.self, forKey: .categoryGroupCode)
        images = []
    }

    init(
        id: Int? = nil,
        accountID: Int,
        description: String,
        visitDate: String,
        placeName: String,
        address: String,
        roadAddress: String,
        images: [UIImage],
        imageURLs: [String]? = nil,
        latitude: Double,
        longitude: Double,
        categoryGroupCode: CategoryGroupCode
    ) {
        self.id = id
        self.accountID = accountID
        self.description = description
        self.visitDate = visitDate
        self.placeName = placeName
        self.address = address
        self.roadAddress = roadAddress
        self.images = images
        self.imageURLs = imageURLs
        self.latitude = latitude
        self.longitude = longitude
        self.categoryGroupCode = categoryGroupCode
    }

    init(imageURLs: [String], registration: PlaceRegistration) {
        self.id = registration.id
        self.accountID = registration.accountID
        self.description = registration.description
        self.visitDate = registration.visitDate
        self.placeName = registration.placeName
        self.address = registration.address
        self.roadAddress = registration.roadAddress
        self.images = registration.images
        self.imageURLs = imageURLs
        self.latitude = registration.latitude
        self.longitude = registration.longitude
        self.categoryGroupCode = registration.categoryGroupCode
    }
}
