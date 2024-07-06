//
//  AddCollectionInteractor.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import Foundation
import RIBs
import RxSwift
import RxCocoa

protocol AddCollectionRouting: ViewableRouting {}

protocol AddCollectionPresentable: Presentable {
    var listener: AddCollectionPresentableListener? { get set }
    var screenType: AddCollectionType { get set }
    func reloadData()
}

protocol AddCollectionListener: AnyObject {
    func closeAddCollection()
    func popCurrentRIB()
    func sendDataToRegistCollection(data: EditSelectedCollectionData)
}

typealias EditSelectedCollectionData = [(IndexPath, PlaceRegistration)]

final class AddCollectionInteractor: PresentableInteractor<AddCollectionPresentable>,
                                     AddCollectionInteractable,
                                     AddCollectionPresentableListener {
    weak var router: AddCollectionRouting?
    weak var listener: AddCollectionListener?
    private let networkService: NetworkServiceDelegate
    private let disposeBag = DisposeBag()

    var locationTotalCount: BehaviorRelay<Int> = .init(value: 0)
    var registeredLocations: BehaviorRelay<[(String, [PlaceRegistration])]> = .init(value: [])
    var selectedLocations: BehaviorRelay<[(IndexPath, PlaceRegistration)]> = .init(value: [])
    var editSelectedCollectionData: EditSelectedCollectionData?

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: AddCollectionPresentable,
        networkService: NetworkServiceDelegate,
        data: EditSelectedCollectionData?
    ) {
        self.networkService = networkService
        if let data {
            selectedLocations.accept(data)
            locationTotalCount.accept(data.count)
        }

        super.init(presenter: presenter)
        presenter.listener = self
    }

    func closeAddCollection() {
        listener?.closeAddCollection()
    }

    func popCurrentRIB() {
        listener?.popCurrentRIB()
    }

    func showRegistLocation() {
        listener?.closeAddCollection()
    }

    func retriveRegistLocation() {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        networkService.request(WhatfleAPI.getAllMyPlace)
            .map { response -> [PlaceRegistration] in
                return try JSONDecoder().decode([PlaceRegistration].self, from: response.data)
            }
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                let data = result.groupedByDate()
                self.registeredLocations.accept(data)
                self.locationTotalCount.accept(data.flatMap { $0.places }.count)
                self.presenter.reloadData()
                LoadingIndicatorService.shared.hideLoading()
            }, onFailure: { error in
                LoadingIndicatorService.shared.hideLoading()
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func selectItem(with indexPath: IndexPath) {
        guard let data = registeredLocations.value[safe: indexPath.section]?.1[safe: indexPath.row] else { return }
        selectedLocations.accept(selectedLocations.value + [(indexPath, data)])
    }

    func deselectItem(with indexPath: IndexPath) {
        guard (registeredLocations.value[safe: indexPath.section]?.1[safe: indexPath.row]) != nil else { return }
        selectedLocations.accept(selectedLocations.value.filter { $0.0 != indexPath })
    }

    func showRegistCollection() {
        let data: EditSelectedCollectionData = selectedLocations.value
        self.listener?.sendDataToRegistCollection(data: data)
    }
}

extension Array where Element == PlaceRegistration {
    func groupedByDate() -> [(date: String, places: [PlaceRegistration])] {
        let groupedDictionary = Dictionary(grouping: self, by: { $0.visitDate.replaceHyphensWithDots() })
        let sortedKeys = groupedDictionary.keys.sorted(by: >)
        return sortedKeys.map { (date: $0, places: groupedDictionary[$0]!) }
    }
}
