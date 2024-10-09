//
//  TotalSearchBarInteractor.swift
//  What?fle
//
//  Created by 이정환 on 10/1/24.
//

import RIBs

import RxCocoa
import RxSwift

protocol TotalSearchBarRouting: ViewableRouting {}

protocol TotalSearchBarPresentable: Presentable {
    var listener: TotalSearchBarPresentableListener? { get set }
}

protocol TotalSearchBarListener: AnyObject {
    func dismissTotalSearchBar()
}

final class TotalSearchBarInteractor: PresentableInteractor<TotalSearchBarPresentable>, TotalSearchBarInteractable, TotalSearchBarPresentableListener {

    private let totalSearchUseCase: TotalSearchUseCaseProtocol
    weak var router: TotalSearchBarRouting?
    weak var listener: TotalSearchBarListener?

    // MARK: - 검색전
    var recommendHashTags: BehaviorRelay<[String]> = .init(value: [])
    var recentTerms: BehaviorRelay<[String]> = .init(value: [])

    // MARK: - 검색후
    var resultData: BehaviorRelay<(tags: [String], collections: [TotalSearchData.CollectionContent.Collection])> = .init(value: (tags: [], collections: []))

    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: TotalSearchBarPresentable,
        totalSearchUseCase: TotalSearchUseCaseProtocol
    ) {
        self.totalSearchUseCase = totalSearchUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        self.setupViews()
    }

    func dismissTotalSearchBar() {
        self.listener?.dismissTotalSearchBar()
    }

    func searchTerm(term: String) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        self.totalSearchUseCase.getSearchData(term: term)
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                UserDefaultsManager.recentSearchSave(type: .home, searchText: term)
                self.recentTerms.accept(UserDefaultsManager.recentSearchLoad(type: .home))
                self.resultData.accept(data)
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: self.disposeBag)
    }

    func setupViews() {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        self.recentTerms.accept(UserDefaultsManager.recentSearchLoad(type: .home))
        self.totalSearchUseCase.getSearchRecommendTag()
            .subscribe(onSuccess: { [weak self] tags in
                guard let self else { return }
                self.recommendHashTags.accept(tags)
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }
}
