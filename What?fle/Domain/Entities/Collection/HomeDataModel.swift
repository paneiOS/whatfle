//
//  HomeDataModel.swift
//  What?fle
//
//  Created by 이정환 on 9/11/24.
//

import Foundation

struct HomeDataModel: Decodable {
    let topSection: TopSection
    let contents: [Content]
    let page: Int
    let pageSize: Int
    let isLastPage: Bool

    enum CodingKeys: String, CodingKey {
        case topSection = "top"
        case contents, page, pageSize, isLastPage
    }

    struct TopSection: Decodable {
        let hashtagName: String
        let collections: [Collection]
    }

    struct Content: Decodable {
        let type: ImageGridType
        let collection: Collection
        let account: Account

        enum CodingKeys: String, CodingKey {
            case type
            case collection
            case account
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = ImageGridType(rawValue: try container.decode(String.self, forKey: .type)) ?? .twoByTwo
            self.collection = try container.decode(Collection.self, forKey: .collection)
            self.account = try container.decode(Account.self, forKey: .account)
        }
    }

    struct Collection: Decodable {
        let id: Int
        let accountID: Int
        let title: String
        let description: String
        let createdAt: String
        let updatedAt: String?
        let deletedAt: String?
        let isPublic: Bool
        let imageURLs: [String]?
        let isActiveCover: Bool
        let hashtags: [Hashtag]
        let places: [Place]

        var convertImageURLs: [String] {
//            return self.imageURLs?.compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) } ?? []
            return ["https://zzfghrhtmemsirwljiei.supabase.co/storage/v1/object/public/place/99a119ad-c42d-4957-8d45-85d08b095bab-1723563240348",
                    "https://zzfghrhtmemsirwljiei.supabase.co/storage/v1/object/public/place/0ea88219-9996-4201-be69-797259c468a1-1723563241351",
                    "https://zzfghrhtmemsirwljiei.supabase.co/storage/v1/object/public/place/ba5055a6-862a-4b99-9d47-8331816bebf5-1723563242565",
                    "https://zzfghrhtmemsirwljiei.supabase.co/storage/v1/object/public/place/063b59f9-0316-4f58-a004-acecb6b6a5d2-1723563243665"]
        }

        enum CodingKeys: String, CodingKey {
            case id
            case accountID = "accountId"
            case title, description, createdAt, updatedAt, deletedAt, isPublic
            case imageURLs = "imageUrls"
            case isActiveCover, hashtags, places
        }

        struct Hashtag: Decodable {
            let id: Int
            let hashtagName: String
        }

        struct Place: Decodable {
            let id: Int
            let address: String
            let latitude: Double
            let longitude: Double
            let accountID: Int
            let createdAt: String
            let deletedAt: String?
            let imageURLs: [String]?
            let placeName: String
            let updatedAt: String?
            let visitDate: String
            let description: String
            let roadAddress: String
            let categoryGroupCode: String?

            enum CodingKeys: String, CodingKey {
                case id, address, latitude, longitude
                case accountID = "accountId"
                case createdAt, deletedAt
                case imageURLs = "imageUrls"
                case placeName, updatedAt, visitDate, description, roadAddress, categoryGroupCode
            }
        }
    }

    struct Account: Decodable {
        let id: Int
        let nickname: String
        let imageURL: String

        enum CodingKeys: String, CodingKey {
            case id, nickname
            case imageURL = "profileImagePath"
        }
    }
}
