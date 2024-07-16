//
//  LoadingIndicator.swift
//  What?fle
//
//  Created by 이정환 on 3/24/24.
//

import UIKit

class LoadingIndicatorService {
    static let shared = LoadingIndicatorService()
    private var window: UIWindow? = UIApplication.shared.keyWindow
    private var dimmedView: UIView?

    private init() {}

    func showLoading() {
        guard let window = window else { return }
        self.dimmedView = UIView(frame: window.bounds)
        self.dimmedView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.dimmedView!.center
        activityIndicator.startAnimating()

        DispatchQueue.main.async {
            self.dimmedView?.addSubview(activityIndicator)
            window.addSubview(self.dimmedView!)
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.dimmedView?.removeFromSuperview()
            self.dimmedView = nil
        }
    }

    func isLoading() -> Bool {
        return dimmedView == nil ? false : true
    }
}
