//
//  TextFieldWithErrorUnderlineDelegate.swift
//  What?fle
//
//  Created by 이정환 on 7/12/24.
//

import UIKit

protocol TextFieldWithErrorUnderlineDelegate: TextFieldWithUnderlineDelegate {
    func activateErrorUnderline()
    func validateText(_ text: String)
}

extension TextFieldWithErrorUnderlineDelegate where Self: UITextField {
    func activateErrorUnderline() {
        underlineView.backgroundColor = .Core.warning
    }

    func validateText(_ text: String) {
        if text.isEmpty {
            activateUnderline()
        } else {
            activateUnderline()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = textField.text as NSString? {
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            self.validateText(updatedText)
        }
        return true
    }
}
