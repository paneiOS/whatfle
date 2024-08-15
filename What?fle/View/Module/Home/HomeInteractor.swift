//
//  HomeInteractor.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import RxSwift

protocol HomeRouting: ViewableRouting {
    func routeToDetailCollection(id: Int)
    func popToDetailCollection()
}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
}

protocol HomeListener: AnyObject {}

final class HomeInteractor: PresentableInteractor<HomePresentable> {

    weak var router: HomeRouting?
    weak var listener: HomeListener?

    override init(presenter: HomePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension HomeInteractor: HomeInteractable {
    func popToDetailCollection() {
        self.router?.popToDetailCollection()
    }
}

extension HomeInteractor: HomePresentableListener {
    func showDetailCollection(id: Int) {
        self.router?.routeToDetailCollection(id: id)
    }
}
