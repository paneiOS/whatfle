//
//  MyPageInteractor.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import RIBs
import RxCocoa
import RxSwift

protocol MyPageRouting: ViewableRouting {
    func routeToDetailCollection(id: Int)
    func popToDetailCollection()
    func routeToDetailLocation(model: HomeDataModel.Collection.Place)
    func popToDetailLocation()
    func routeToMyCollections()
    func routeToMyLocations()
    func popToMyContents()
}

protocol MyPagePresentable: Presentable {
    var listener: MyPagePresentableListener? { get set }
}

protocol MyPageListener: AnyObject {}

final class MyPageInteractor: PresentableInteractor<MyPagePresentable>, MyPageInteractable {
    weak var router: MyPageRouting?
    weak var listener: MyPageListener?
    private let collectionUseCase: CollectionUseCaseProtocol
    private let disposeBag = DisposeBag()

    var myPageDataModel: PublishRelay<MyPageDataModel> = .init()

    init(presenter: MyPagePresentable, collectionUseCase: CollectionUseCaseProtocol) {
        self.collectionUseCase = collectionUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension MyPageInteractor: MyPagePresentableListener {
    func loadData() {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        collectionUseCase.getMyPageData()
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                self.myPageDataModel.accept(data)
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func showDetailCollection(id: Int) {
        self.router?.routeToDetailCollection(id: id)
    }

    func popToDetailCollection() {
        self.router?.popToDetailCollection()
    }

    func showDetailLocation(model: HomeDataModel.Collection.Place) {
        self.router?.routeToDetailLocation(model: model)
    }

    func popToDetailLocation() {
        self.router?.popToDetailLocation()
    }

    func showMyLocations() {
        self.router?.routeToMyLocations()
    }

    func showMyCollections() {
        self.router?.routeToMyCollections()
    }

    func popToMyContents() {
        self.router?.popToMyContents()
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
