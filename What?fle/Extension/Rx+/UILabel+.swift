//
//  UILabel+.swift
//  What?fle
//
//  Created by 이정환 on 4/2/24.
//

// import RxSwift
// import RxCocoa
// import UIKit
//
// extension Reactive where Base: UILabel {
//    public var text: ControlProperty<String?> {
//        let source: Observable<String?> = self.observe(String.self, "text")
//            .map { $0 }
//        
//        let observer = Binder(self.base) { label, text: String? in
//            label.text = text
//        }
//        
//        return ControlProperty(values: source, valueSink: observer)
//    }
// }
