//
//  TextFieldWithUnderlineProtocol.swift
//  What?fle
//
//  Created by 이정환 on 7/12/24.
//

import UIKit
import SnapKit

protocol TextFieldWithUnderlineProtocol: UITextFieldDelegate {
    var underlineView: UIView { get }
    func setupUI()
    func activateUnderline()
    func deactivateUnderline()
    func activateErrorUnderline()
}

extension TextFieldWithUnderlineProtocol where Self: UITextField {
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

    func activateErrorUnderline() {
        underlineView.backgroundColor = .Core.warning
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activateUnderline()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        deactivateUnderline()
    }
}
