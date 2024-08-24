//
//  TextFieldWithUnderlineProtocol.swift
//  What?fle
//
//  Created by 이정환 on 7/12/24.
//

import SnapKit
import UIKit

protocol TextFieldWithUnderlineDelegate: UITextFieldDelegate {
    var underlineView: UIView { get }
    func setupUI()
    func activateUnderline()
    func deactivateUnderline()
}

extension TextFieldWithUnderlineDelegate where Self: UITextField {
    func setupUI() {
        self.delegate = self

        addSubview(underlineView)
        underlineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func activateUnderline() {
        underlineView.backgroundColor = .Core.primary
    }

    func deactivateUnderline() {
        underlineView.backgroundColor = .lineDefault
    }
}
