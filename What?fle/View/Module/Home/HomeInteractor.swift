//
//  HomeInteractor.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import RxCocoa
import RxSwift

protocol HomeRouting: ViewableRouting {
    func routeToDetailCollection(id: Int)
    func popToDetailCollection()
    func showLoginRIB()
    func dismissLoginRIB()
}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
}

protocol HomeListener: AnyObject {}

final class HomeInteractor: PresentableInteractor<HomePresentable> {

    weak var router: HomeRouting?
    weak var listener: HomeListener?

    var homeData: BehaviorRelay<HomeDataModel?> = .init(value: nil)

    private let collectionUseCase: CollectionUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(presenter: HomePresentable, collectionUseCase: CollectionUseCaseProtocol) {
        self.collectionUseCase = collectionUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension HomeInteractor: HomeInteractable {
    func dismissLoginRIB() {
        self.router?.dismissLoginRIB()
    }

    func popToDetailCollection() {
        self.router?.popToDetailCollection()
    }
}

extension HomeInteractor: HomePresentableListener {
    func showDetailCollection(id: Int) {
        self.router?.routeToDetailCollection(id: id)
    }

    func showLoginRIB() {
        self.router?.showLoginRIB()
    }
    
    func loadData(page: Int, pageSize: Int) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()
        
        collectionUseCase.getHomeData(page: page, pageSize: pageSize)
            .subscribe(onSuccess: { [weak self] homeData in
                guard let self else { return }
                self.homeData.accept(homeData)
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }
}
