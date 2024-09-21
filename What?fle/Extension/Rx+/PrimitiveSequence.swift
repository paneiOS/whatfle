//
//  PrimitiveSequence.swift
//  What?fle
//
//  Created by JeongHwan Lee on 9/8/24.
//

import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    func mapToVoid() -> Single<Void> {
        return self.map { _ in () }
    }
}
