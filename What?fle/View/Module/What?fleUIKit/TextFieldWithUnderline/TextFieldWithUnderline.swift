//
//  TextFieldWithUnderline.swift
//  What?fle
//
//  Created by JeongHwan Lee on 3/31/24.
//

import SnapKit
import UIKit

class TextFieldWithUnderline: UITextField, TextFieldWithUnderlineProtocol {
    let underlineView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .lineDefault
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

extension TextFieldWithUnderline: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activateUnderline()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        deactivateUnderline()
    }
}
