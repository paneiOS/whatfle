//
//  ScrollKeyboardVC.swift
//  What?fle
//
//  Created by 이정환 on 9/22/24.
//

import UIKit

class ScrollKeyboardVC: UIViewController, UIGestureRecognizerDelegate {

    private var isKeyboardVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard !self.isKeyboardVisible,
              let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
              let scrollView = self.view.findScrollView(),
              let activeField = self.view.findFirstResponder() else {
            return
        }
        let activeFieldFrameInScrollView = scrollView.convert(activeField.frame, from: activeField.superview)
        let overlapHeight = (activeFieldFrameInScrollView.maxY + 20) - (scrollView.frame.height - keyboardHeight)
        if overlapHeight > 0 {
            let scrollPoint = CGPoint(x: 0, y: scrollView.contentOffset.y + overlapHeight)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
        self.isKeyboardVisible = true
    }

    @objc private func keyboardWillHide() {
        if self.isKeyboardVisible, let scrollView = self.view.findScrollView() {
            self.view.endEditing(true)
            scrollView.setContentOffset(.zero, animated: false)
        }
        self.isKeyboardVisible = false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
}
