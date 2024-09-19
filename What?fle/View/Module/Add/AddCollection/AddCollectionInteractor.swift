//
//  AddCollectionInteractor.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import Foundation

import RIBs
import RxCocoa
import RxSwift

protocol AddCollectionRouting: ViewableRouting {}

protocol AddCollectionPresentable: Presentable {
    var listener: AddCollectionPresentableListener? { get set }
    var screenType: AddCollectionType { get set }
    func reloadData()
}

protocol AddCollectionListener: AnyObject {
    func popToAddCollection()
    func dismissAddCollection()
    func closeAddCollection()
    func popToRegistCollection()
    func routeToRegistLocation()
    func sendDataToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel])
}

typealias EditSelectedCollectionData = [(IndexPath, PlaceRegistration)]

final class AddCollectionInteractor: PresentableInteractor<AddCollectionPresentable>,
                                     AddCollectionInteractable,
                                     AddCollectionPresentableListener {
    weak var router: AddCollectionRouting?
    weak var listener: AddCollectionListener?

    var locationTotalCount: BehaviorRelay<Int> = .init(value: 0)
    var registeredLocations: BehaviorRelay<[(String, [PlaceRegistration])]> = .init(value: [])
    var selectedLocations: BehaviorRelay<[(IndexPath, PlaceRegistration)]> = .init(value: [])
    var editSelectedCollectionData: EditSelectedCollectionData?

    private let locationUseCase: LocationUseCaseProtocol
    private let collectionUseCase: CollectionUseCaseProtocol
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: AddCollectionPresentable,
        locationUseCase: LocationUseCaseProtocol,
        collectionUseCase: CollectionUseCaseProtocol,
        data: EditSelectedCollectionData?
    ) {
        self.locationUseCase = locationUseCase
        self.collectionUseCase = collectionUseCase
        if let data {
            selectedLocations.accept(data)
            locationTotalCount.accept(data.count)
        }

        super.init(presenter: presenter)
        presenter.listener = self
    }

    func popToAddCollection() {
        listener?.popToAddCollection()
    }

    func dismissAddCollection() {
        listener?.dismissAddCollection()
    }

    func completeRegistCollection() {
        listener?.closeAddCollection()
    }

    func popToRegistCollection() {
        listener?.popToRegistCollection()
    }

    func showRegistLocation() {
        listener?.routeToRegistLocation()
    }

    func retriveRegistLocation() {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        self.locationUseCase.getAllMyPlace()
            .subscribe(onSuccess: { [weak self] data in
                guard let self else { return }
                self.registeredLocations.accept(data)
                self.locationTotalCount.accept(data.flatMap { $0.places }.count)
                self.presenter.reloadData()
            }, onFailure: { error in
                print("\(self) Error: \(error)")
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
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
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        self.collectionUseCase.getRecommendHashtag()
            .subscribe(onSuccess: { [weak self] tags in
                guard let self else { return }
                self.listener?.sendDataToRegistCollection(data: selectedLocations.value, tags: tags)
            }, onFailure: { error in
                print("\(self) Error: \(error)")
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }
}
