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

        Single.zip(
            networkService.request(CollectionAPI.getDetailCollection(self.collectionID)),
            networkService.request(MyPageAPI.getMyFavoriteLocationIDs)
        )
        .subscribe(onSuccess: { [weak self] (detailCollection: DetailCollectionModel, favoriteLocations: [Int]) in
            guard let self else { return }
            var updatedDetailCollection = detailCollection
            updatedDetailCollection.places = detailCollection.places.compactMap { place in
                guard let id = place.id else { return nil }
                var modifiedPlace = place
                modifiedPlace.isFavorite = favoriteLocations.contains(id)
                return modifiedPlace
            }
            self.detailCollectionModel.onNext(updatedDetailCollection)
        }, onFailure: { error in
            errorPrint(error)
        }, onDisposed: {
            LoadingIndicatorService.shared.hideLoading()
        })
        .disposed(by: disposeBag)
    }

    func popToDetailCollection() {
        listener?.popToDetailCollection()
    }

    func updateFavoriteLocation(id: Int, isFavorite: Bool) {
        networkService.request(CollectionAPI.updateFavoriteLocation(id: id, isFavorite: isFavorite))
            .subscribe(onSuccess: {_ in })
            .disposed(by: disposeBag)
    }
}
