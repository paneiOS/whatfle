//
//  DetailCollectionInteractor.swift
//  What?fle
//
//  Created by 이정환 on 8/1/24.
//

import Foundation
import RIBs
import RxSwift

protocol DetailCollectionRouting: ViewableRouting {}

protocol DetailCollectionPresentable: Presentable {
    var listener: DetailCollectionPresentableListener? { get set }
}

protocol DetailCollectionListener: AnyObject {
    func popToDetailCollection()
}

final class DetailCollectionInteractor: PresentableInteractor<DetailCollectionPresentable>, DetailCollectionInteractable, DetailCollectionPresentableListener {

    weak var router: DetailCollectionRouting?
    weak var listener: DetailCollectionListener?

    private let networkService: NetworkServiceDelegate
    private let collectionID: Int
    private let disposeBag = DisposeBag()
    var detailCollectionModel: PublishSubject<DetailCollectionModel> = .init()

    deinit {
        print("\(self) is being deinit")
    }

    init(presenter: DetailCollectionPresentable, networkService: NetworkServiceDelegate, collectionID: Int) {
        self.networkService = networkService
        self.collectionID = collectionID
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func retriveDetailCollection() {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        networkService.request(WhatfleAPI.getDetailCollection(self.collectionID))
            .map { response -> DetailCollectionModel in
                return try JSONDecoder().decode(DetailCollectionModel.self, from: response.data)
            }
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                self.detailCollectionModel.onNext(result)
                LoadingIndicatorService.shared.hideLoading()
            }, onFailure: { error in
                LoadingIndicatorService.shared.hideLoading()
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func popToDetailCollection() {
        listener?.popToDetailCollection()
    }
}
