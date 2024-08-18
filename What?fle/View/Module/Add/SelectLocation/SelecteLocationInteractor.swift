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
    private let networkService: NetworkServiceDelegate
    private let disposeBag = DisposeBag()

    var searchResultArray = BehaviorRelay<[KakaoSearchDocumentsModel]>(value: [])
    var recentKeywordArray = BehaviorRelay<[String]>(value: UserDefaultsManager.recentSearchLoad())

    init(presenter: SelectLocationPresentable, networkService: NetworkServiceDelegate) {
        self.networkService = networkService
        super.init(presenter: presenter)
        presenter.listener = self
    }

    deinit {
        print("\(self) is being deinit")
    }

    func performSearch(with query: String, more: Bool) {
        guard !LoadingIndicatorService.shared.isLoading() else {
            return
        }
        LoadingIndicatorService.shared.showLoading()
        networkService.request(KakaoAPI.search(query, currentPage(more: more)))
            .map { response -> [KakaoSearchDocumentsModel] in
                let searchResults = try JSONDecoder().decode(KakaoSearchModel.self, from: response.data)
                return searchResults.documents
            }
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                UserDefaultsManager.recentSearchSave(searchText: query)
                if more {
                    self.searchResultArray.accept(self.searchResultArray.value + result)
                } else {
                    self.searchResultArray.accept(result)
                }
                LoadingIndicatorService.shared.hideLoading()
            }, onFailure: { error in
                print("Error: \(error)")
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func closeView() {
        self.listener?.closeSelectLocation()
    }

    func deleteItem(at index: Int) {
        let updateRecentSearch = UserDefaultsManager.recentSearchRemove(index: index)
        recentKeywordArray.accept(updateRecentSearch)
    }

    func allDeleteItem() {
        UserDefaultsManager.recentSearchAllRemove()
        recentKeywordArray.accept([])
    }

    func selectItem(at index: Int) {
        guard let data = searchResultArray.value[safe: index] else { return }
        self.listener?.didSelect(data: data)
    }

    func refreshRecentKeywordArray() {
        self.recentKeywordArray.accept(UserDefaultsManager.recentSearchLoad())
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
