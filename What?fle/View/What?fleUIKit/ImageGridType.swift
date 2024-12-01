//
//  ImageGridType.swift
//  What?fle
//
//  Created by 이정환 on 9/11/24.
//

import UIKit

enum ImageGridType: String {
    case none
    case type1
    case type2
    case type3
    case type4

    var cellHeight: CGFloat {
        switch self {
        case .type3:
            return 298
        case .type4:
            return 378
        default:
            return UIApplication.shared.width + 38 + 92 + 16
        }
    }

    var imageHeight: CGFloat {
        switch self {
        case .type3:
            120
        case .type4:
            200
        default:
            UIApplication.shared.width
        }
    }
}
