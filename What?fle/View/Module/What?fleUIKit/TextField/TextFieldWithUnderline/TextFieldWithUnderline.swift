//
//  TextFieldWithUnderline.swift
//  What?fle
//
//  Created by JeongHwan Lee on 3/31/24.
//

import SnapKit
import UIKit

class TextFieldWithUnderline: UITextField, TextFieldWithUnderlineDelegate {
    let underlineView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .lineDefault
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

extension TextFieldWithUnderline: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activateUnderline()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.deactivateUnderline()
    }
}
