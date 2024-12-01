//
//  MyContentsInteractor.swift
//  What?fle
//
//  Created by 이정환 on 12/1/24.
//

import RIBs
import RxCocoa
import RxSwift

protocol MyContentsRouting: ViewableRouting {}

protocol MyContentsPresentable: Presentable {
    var listener: MyContentsPresentableListener? { get set }
}

protocol MyContentsListener: AnyObject {
    func popToMyContents()
}

final class MyContentsInteractor: PresentableInteractor<MyContentsPresentable>, MyContentsInteractable {
    private let collectionUseCase: CollectionUseCaseProtocol
    private let disposeBag = DisposeBag()

    var myFavoritePlaces: BehaviorRelay<[HomeDataModel.Collection.Place]> = .init(value: [])
    var myFavoriteCollections: BehaviorRelay<[HomeDataModel.Collection]> = .init(value: [])

    weak var router: MyContentsRouting?
    weak var listener: MyContentsListener?

    deinit {
        print("\(self) is being deinit")
    }

    init(presenter: MyContentsPresentable, collectionUseCase: CollectionUseCaseProtocol) {
        self.collectionUseCase = collectionUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension MyContentsInteractor: MyContentsPresentableListener {
    func retriveMyFavorites() {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        Single.zip(
            collectionUseCase.getMyFavoriteLocation().map { data in
                data.map { place -> HomeDataModel.Collection.Place in
                    var modifiedPlace = place
                    modifiedPlace.isFavorite = true
                    return modifiedPlace
                }
            },
            collectionUseCase.getMyFavoriteCollection().map { data in
                data.map { collection -> HomeDataModel.Collection in
                    var modifiedCollection = collection
                    modifiedCollection.isFavorite = true
                    return modifiedCollection
                }
            }
        )
        .subscribe(onSuccess: { [weak self] places, collections in
            guard let self else { return }
            self.myFavoritePlaces.accept(places)
            self.myFavoriteCollections.accept(collections)
        }, onFailure: { error in
            errorPrint(error)
        }, onDisposed: {
            LoadingIndicatorService.shared.hideLoading()
        })
        .disposed(by: disposeBag)
    }

    func popToMyContents() {
        listener?.popToMyContents()
    }

    func updateFavoriteLocation(id: Int, isFavorite: Bool) {
        collectionUseCase.updateFavoriteLocation(id: id, isFavorite: isFavorite)
            .subscribe(onSuccess: {})
            .disposed(by: disposeBag)
    }

    func updateFavoriteCollection(id: Int, isFavorite: Bool) {
        collectionUseCase.updateFavoriteCollection(id: id, isFavorite: isFavorite)
            .subscribe(onSuccess: {})
            .disposed(by: disposeBag)
    }
}
