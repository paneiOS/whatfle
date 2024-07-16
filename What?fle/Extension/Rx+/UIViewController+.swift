//
//  UIViewController+.swift
//  What?fle
//
//  Created by 이정환 on 4/7/24.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
}
