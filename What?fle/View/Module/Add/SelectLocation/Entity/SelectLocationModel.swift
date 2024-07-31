//
//  SelectLocationModel.swift
//  What?fle
//
//  Created by 이정환 on 3/1/24.
//

import UIKit

struct KakaoSearchModel: Decodable {
    let meta: KakaoSearchMetaModel
    let documents: [KakaoSearchDocumentsModel]

    enum CodingKeys: String, CodingKey {
        case meta
        case documents
    }
}

struct KakaoSearchMetaModel: Decodable {
    let sameName: KakaoSearchSameNameModel
    let pageableCount: Int
    let totalCount: Int
    let isEnd: Bool

    enum CodingKeys: String, CodingKey {
        case sameName = "same_name"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
        case isEnd = "is_end"
    }
}

struct KakaoSearchSameNameModel: Decodable {
    let region: [String]
    let keyword: String
    let selectedRegion: String

    enum CodingKeys: String, CodingKey {
        case region
        case keyword
        case selectedRegion = "selected_region"
    }
}

enum CategoryGroupCode: String, Decodable {
    case mt1 = "MT1"
    case cs2 = "CS2"
    case sc4 = "SC4"
    case ac5 = "AC5"
    case pk6 = "PK6"
    case ol7 = "O17"
    case sw8 = "SW8"
    case bk9 = "BK9"
    case ad5 = "AD5"
    case fd6 = "FD6"
    case ce7 = "CE7"
    case hp8 = "HP8"
    case pm9 = "PM9"
    case unknown

    var image: UIImage? {
        switch self {
        case .mt1: return .cart
        case .cs2: return .store
        case .sc4, .ac5: return .school
        case .pk6: return .parking
        case .ol7: return .vehicle
        case .sw8: return .train
        case .bk9: return .bank
        case .ad5: return .lodging
        case .fd6: return .food
        case .ce7: return .cafe
        case .hp8: return .hospital
        case .pm9: return .pharmacy
        default: return .placeholdCell
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String?.self)
        self = CategoryGroupCode(rawValue: rawValue ?? "") ?? .unknown
    }
}

struct KakaoSearchDocumentsModel: Decodable, Equatable {
    let placeName: String
    let distance: String
    let placeURL: String
    let categoryName: String
    let addressName: String
    let roadAddressName: String
    let id: String
    let phone: String
    let categoryGroupCode: CategoryGroupCode
    let categoryGroupName: String
    let longitudeX: String
    let latitudeY: String

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case distance
        case placeURL = "place_url"
        case categoryName = "category_name"
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
        case id
        case phone
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case longitudeX = "x"
        case latitudeY = "y"
    }

    var longitude: Double {
        Double(longitudeX) ?? 0.0
    }

    var latitude: Double {
        Double(latitudeY) ?? 0.0
    }
}
