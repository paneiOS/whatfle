//
//  BottomKeyboardVC.swift
//  What?fle
//
//  Created by 이정환 on 9/22/24.
//

import UIKit

class BottomKeyboardVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        self.view.frame.origin.y = -keyboardHeight
    }

    @objc private func keyboardWillHide() {
        self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
}
