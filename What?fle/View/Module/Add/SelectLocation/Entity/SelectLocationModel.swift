//
//  SelectLocationModel.swift
//  What?fle
//
//  Created by 이정환 on 3/1/24.
//

import Foundation

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

struct KakaoSearchDocumentsModel: Decodable, Equatable {
    let placeName: String
    let distance: String
    let placeURL: String
    let categoryName: String
    let addressName: String
    let roadAddressName: String
    let id: String
    let phone: String
    let categoryGroupCode: String
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
