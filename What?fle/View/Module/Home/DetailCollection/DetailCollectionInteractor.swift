//
//  DetailCollectionInteractor.swift
//  What?fle
//
//  Created by 이정환 on 8/1/24.
//

import RIBs
import RxSwift

protocol DetailCollectionRouting: ViewableRouting {}

protocol DetailCollectionPresentable: Presentable {
    var listener: DetailCollectionPresentableListener? { get set }
}

protocol DetailCollectionListener: AnyObject {}

final class DetailCollectionInteractor: PresentableInteractor<DetailCollectionPresentable>, DetailCollectionInteractable, DetailCollectionPresentableListener {

    weak var router: DetailCollectionRouting?
    weak var listener: DetailCollectionListener?

    override init(presenter: DetailCollectionPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
