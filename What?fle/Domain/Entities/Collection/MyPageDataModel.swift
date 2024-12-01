//
//  MyPageDataModel.swift
//  What?fle
//
//  Created by 이정환 on 11/6/24.
//

import Foundation

struct MyPageDataModel: Decodable {
    let collections: [HomeDataModel.Collection]
    let places: [HomeDataModel.Collection.Place]
}
