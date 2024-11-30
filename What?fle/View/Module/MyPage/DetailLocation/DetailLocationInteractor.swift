//
//  DetailLocationInteractor.swift
//  What?fle
//
//  Created by 이정환 on 11/30/24.
//

import RIBs
import RxSwift

protocol DetailLocationRouting: ViewableRouting {}

protocol DetailLocationPresentable: Presentable {
    var listener: DetailLocationPresentableListener? { get set }
}

protocol DetailLocationListener: AnyObject {
    func popToDetailLocation()
}

final class DetailLocationInteractor: PresentableInteractor<DetailLocationPresentable>, DetailLocationInteractable, DetailLocationPresentableListener {

    weak var router: DetailLocationRouting?
    weak var listener: DetailLocationListener?

    private let networkService: NetworkServiceDelegate
    private let disposeBag = DisposeBag()
    var detailLocationModel: HomeDataModel.Collection.Place

    deinit {
        print("\(self) is being deinit")
    }

    init(presenter: DetailLocationPresentable, networkService: NetworkServiceDelegate, detailLocationModel: HomeDataModel.Collection.Place) {
        self.networkService = networkService
        self.detailLocationModel = detailLocationModel
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func popToDetailLocation() {
        listener?.popToDetailLocation()
    }
}
