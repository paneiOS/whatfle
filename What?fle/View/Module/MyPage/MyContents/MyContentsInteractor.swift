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
    func retriveMyFavoriteCollection() {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        collectionUseCase.getMyFavoriteCollection()
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                let updatedData = data.map { collection -> HomeDataModel.Collection in
                    var modifiedCollection = collection
                    modifiedCollection.isFavorite = true
                    return modifiedCollection
                }

                self.myFavoriteCollections.accept(updatedData)
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

    func updateFavorite(id: Int, isFavorite: Bool) {
        collectionUseCase.updateFavorite(id: id, isFavorite: isFavorite)
            .subscribe(onSuccess: {})
            .disposed(by: disposeBag)
    }
}
