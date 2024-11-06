//
//  MyPageInteractor.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import RIBs
import RxCocoa
import RxSwift

protocol MyPageRouting: ViewableRouting {}

protocol MyPagePresentable: Presentable {
    var listener: MyPagePresentableListener? { get set }
}

protocol MyPageListener: AnyObject {}

final class MyPageInteractor: PresentableInteractor<MyPagePresentable>, MyPageInteractable, MyPagePresentableListener {

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
}
