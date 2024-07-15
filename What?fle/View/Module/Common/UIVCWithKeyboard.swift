//
//  UIVCWithKeyboard.swift
//  What?fle
//
//  Created by 이정환 on 4/22/24.
//

import UIKit

class UIVCWithKeyboard: UIViewController {
    private var scrollView: UIScrollView?
    private var keyboardHeight: CGFloat = 0
    private var initialContentInset: UIEdgeInsets = .zero
    private var initialVerticalScrollIndicatorInsets: UIEdgeInsets = .zero
    private var initialHorizontalScrollIndicatorInsets: UIEdgeInsets = .zero

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScrollView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    private func setupScrollView() {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                self.scrollView = scrollView
                initialContentInset = scrollView.contentInset
                initialVerticalScrollIndicatorInsets = scrollView.verticalScrollIndicatorInsets
                initialHorizontalScrollIndicatorInsets = scrollView.horizontalScrollIndicatorInsets
                break
            }
        }
    }

    private func setupKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue else {
            return
        }
        keyboardHeight = keyboardSize.height

        guard let scrollView = scrollView else {
            self.view.frame.origin.y = -keyboardHeight
            return
        }

        var contentInset = scrollView.contentInset
        contentInset.bottom = keyboardHeight
        scrollView.contentInset = contentInset
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        scrollView.horizontalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let scrollView = scrollView else {
            self.view.frame.origin.y = 0
            return
        }

        scrollView.contentInset = initialContentInset
        scrollView.verticalScrollIndicatorInsets = initialVerticalScrollIndicatorInsets
        scrollView.horizontalScrollIndicatorInsets = initialHorizontalScrollIndicatorInsets
    }
}

extension UIVCWithKeyboard: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if touchView is UIButton ||
                touchView is UICollectionView ||
                touchView.superview is UICollectionViewCell {
                return false
            }
        }
        return true
    }
}
