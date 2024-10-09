//
//  SelectLocationInteractor.swift
//  What?fle
//
//  Created by 이정환 on 2/25/24.
//

import Foundation
import RIBs
import RxSwift
import RxCocoa

protocol SelectLocationRouting: ViewableRouting {}

protocol SelectLocationPresentable: Presentable {
    var listener: SelectLocationPresentableListener? { get set }
}

protocol SelectLocationListener: AnyObject {
    func didSelect(data: KakaoSearchDocumentsModel)
    func closeSelectLocation()
}

final class SelectLocationInteractor: PresentableInteractor<SelectLocationPresentable>,
                                      SelectLocationInteractable,
                                      SelectLocationPresentableListener {
    weak var router: SelectLocationRouting?
    weak var listener: SelectLocationListener?
    private let locationUseCase: LocationUseCaseProtocol

    private let disposeBag = DisposeBag()

    var searchResultArray = BehaviorRelay<[KakaoSearchDocumentsModel]>(value: [])
    var recentKeywordArray = BehaviorRelay<[String]>(value: UserDefaultsManager.recentSearchLoad(type: .location))

    init(presenter: SelectLocationPresentable, locationUseCase: LocationUseCaseProtocol) {
        self.locationUseCase = locationUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }

    deinit {
        print("\(self) is being deinit")
    }

    func performSearch(with query: String, more: Bool) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        self.locationUseCase.search(query, currentPage(more: more))
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                UserDefaultsManager.recentSearchSave(type: .location, searchText: query)
                if more {
                    self.searchResultArray.accept(self.searchResultArray.value + result)
                } else {
                    self.searchResultArray.accept(result)
                }
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func closeView() {
        self.listener?.closeSelectLocation()
    }

    func deleteItem(at index: Int) {
        let updateRecentSearch = UserDefaultsManager.recentSearchRemove(type: .location, index: index)
        recentKeywordArray.accept(updateRecentSearch)
    }

    func allDeleteItem() {
        UserDefaultsManager.historyAllRemove(type: .location)
        recentKeywordArray.accept([])
    }

    func selectItem(at index: Int) {
        guard let data = searchResultArray.value[safe: index] else { return }
        self.listener?.didSelect(data: data)
    }

    func refreshRecentKeywordArray() {
        self.recentKeywordArray.accept(UserDefaultsManager.recentSearchLoad(type: .location))
    }
}

extension SelectLocationInteractor {
    private func currentPage(more: Bool) -> Int {
        if !more {
            return 1
        }

        if searchResultArray.value.isEmpty {
            return 1
        } else {
            return (searchResultArray.value.count / 15) + 1
        }
    }
}
