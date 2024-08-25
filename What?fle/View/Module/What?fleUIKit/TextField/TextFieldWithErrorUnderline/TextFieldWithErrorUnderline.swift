//
//  TextFieldWithErrorUnderline.swift
//  What?fle
//
//  Created by 이정환 on 7/12/24.
//

import UIKit

final class TextFieldWithErrorUnderline: TextFieldWithUnderline, TextFieldWithErrorUnderlineDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            self.validateText(text)
        }
    }
}
