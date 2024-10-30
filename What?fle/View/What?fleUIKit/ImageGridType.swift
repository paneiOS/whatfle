//
//  ImageGridType.swift
//  What?fle
//
//  Created by 이정환 on 9/11/24.
//

import UIKit

enum ImageGridType: String {
    case twoByTwo = "type1"
//    case oneByFour = "type2"
    
    var cellHeight: CGFloat {
        switch self {
        case .twoByTwo:
            return UIApplication.shared.width + 38 + 92 + 16
//        case .oneByFour:
//            return 100
        default:
            return UIApplication.shared.width + 38 + 92 + 16
            
        }
    }
}

//final class ImageView: UIImageView {
//
//    override init(image: UIImage? = .placehold) {
//        super.init(image: image)
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//}
