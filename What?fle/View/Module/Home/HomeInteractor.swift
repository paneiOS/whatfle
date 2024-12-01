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
    func routeToTotalSearchBar()
    func dismissTotalSearchBar()
    func showLoginRIB()
    func dismissLoginRIB(completion: (() -> Void)?)
    func proceedToNextScreenAfterLogin()
}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
}

protocol HomeListener: AnyObject {}

final class HomeInteractor: PresentableInteractor<HomePresentable> {

    weak var router: HomeRouting?
    weak var listener: HomeListener?
    private let collectionUseCase: CollectionUseCaseProtocol
    private let disposeBag = DisposeBag()

    var homeData: BehaviorRelay<HomeDataModel?> = .init(value: nil)
    var currentPage: Int = 1
    let pageSize: Int = 20

    init(presenter: HomePresentable, collectionUseCase: CollectionUseCaseProtocol) {
        self.collectionUseCase = collectionUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension HomeInteractor: HomeInteractable {
    func proceedToNextScreenAfterLogin() {
        self.router?.proceedToNextScreenAfterLogin()
    }

    func dismissLoginRIB() {
        self.router?.dismissLoginRIB(completion: nil)
    }

    func popToDetailCollection() {
        self.router?.popToDetailCollection()
    }

    func dismissTotalSearchBar() {
        self.router?.dismissTotalSearchBar()
    }
}

extension HomeInteractor: HomePresentableListener {
    func showDetailCollection(id: Int) {
        self.router?.routeToDetailCollection(id: id)
    }

    func showTotalSearchBar() {
        self.router?.routeToTotalSearchBar()
    }

    func showLoginRIB() {
        self.router?.showLoginRIB()
    }

    func loadData(more: Bool) {
        if more, let isLastPage = self.homeData.value?.isLastPage, isLastPage {
            return
        }

        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        self.currentPage = more ? self.currentPage + 1 :  1

        collectionUseCase.getHomeData(page: currentPage, pageSize: pageSize)
            .subscribe(onSuccess: { [weak self] homeData in
                guard let self else { return }
                if !more {
                    self.homeData.accept(homeData)
                } else {
                    guard var tempHomedata = self.homeData.value else { return }
                    tempHomedata.contents += homeData.contents
                    self.homeData.accept(HomeDataModel(prevData: tempHomedata, homeData: homeData))
                }
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func updateFavoriteCollection(id: Int, isFavorite: Bool) {
        collectionUseCase.updateFavoriteCollection(id: id, isFavorite: isFavorite)
            .subscribe(onSuccess: {})
            .disposed(by: disposeBag)
    }
}
