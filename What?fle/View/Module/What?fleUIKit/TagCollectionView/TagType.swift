//
//  TagType.swift
//  What?fle
//
//  Created by 이정환 on 7/10/24.
//

import UIKit

enum TagType: Equatable {
    case addedSelectedButton(String)
    case selected(RecommendHashTagModel)
    case deselected(RecommendHashTagModel)

    var title: String {
        switch self {
        case .addedSelectedButton(let title):
            return title
        case .selected(let model),
             .deselected(let model):
            return model.hashtagName
        }
    }
    
    var id: Int {
        switch self {
        case .selected(let model),
             . deselected(let model):
            return model.id
        case .addedSelectedButton:
            // TODO: - 로그인 로직 개발 이후 수정(Pane)
            return -1
        }
    }

    var font: UIFont {
        return .body14MD
    }

    var width: CGFloat {
        switch self {
        case .addedSelectedButton:
            let attributedString = NSAttributedString(string: self.title, attributes: [.font: self.font])
            return ceil(attributedString.size().width) + 52
        default:
            let attributedString = NSAttributedString(string: self.title, attributes: [.font: self.font])
            return ceil(attributedString.size().width) + 24
        }
    }

    var height: CGFloat {
        return 32
    }

    func toggle() -> TagType {
        switch self {
        case .selected(let title):
            return .deselected(title)
        case .deselected(let title):
            return .selected(title)
        default: return self
        }
    }
}
