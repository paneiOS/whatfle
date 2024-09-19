//
//  RegistCollectionInteractor.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import UIKit

import Moya
import RIBs
import RxSwift
import RxCocoa

protocol RegistCollectionRouting: ViewableRouting {
    func routeToAddCollection(data: EditSelectedCollectionData)
    func dismissAddCollection()
    func routeToAddTag(tags: [TagType])
    func closeAddTag()
    func showCustomAlbum()
    func closeCustomAlbum()
}

protocol RegistCollectionPresentable: Presentable {
    var listener: RegistCollectionPresentableListener? { get set }
}

protocol RegistCollectionListener: AnyObject {
    func popToRegistCollection()
    func completeRegistCollection()
}

final class RegistCollectionInteractor: PresentableInteractor<RegistCollectionPresentable>,
                                        RegistCollectionInteractable,
                                        RegistCollectionPresentableListener {
    weak var router: RegistCollectionRouting?
    weak var listener: RegistCollectionListener?

    var selectedImage: BehaviorRelay<UIImage?> = .init(value: nil)
    var tags: BehaviorRelay<[TagType]>
    var isHiddenDimmedView: BehaviorRelay<Bool> = .init(value: true)
    let selectedLocations: BehaviorRelay<[PlaceRegistration]>
    var editSelectedCollectionData: EditSelectedCollectionData

    private let locationUseCase: LocationUseCaseProtocol
    private let collectionUseCase: CollectionUseCaseProtocol
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: RegistCollectionPresentable,
        locationUseCase: LocationUseCaseProtocol,
        collectionUseCase: CollectionUseCaseProtocol,
        data: EditSelectedCollectionData,
        tags: [RecommendHashTagModel]
    ) {
        self.locationUseCase = locationUseCase
        self.collectionUseCase = collectionUseCase
        self.editSelectedCollectionData = data
        self.tags = .init(value: tags.map { .deselected(.init(id: $0.id, hashtagName: $0.hashtagName)) })
        self.selectedLocations = .init(value: data.map { $0.1 })
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func buttonTapped(index: Int) {
        var currentTags: [TagType] = tags.value
        if let tag = currentTags[safe: index]?.toggle() {
            currentTags[index] = tag
            tags.accept(currentTags)
        }
    }

    func showCustomAlbum() {
        router?.showCustomAlbum()
    }

    func closeCustomAlbum() {
        router?.closeCustomAlbum()
    }

    func addPhotos(images: [UIImage]) {
        guard let image = images.first else { return }
        self.selectedImage.accept(image)
        router?.closeCustomAlbum()
    }

    func removeImage() {
        self.selectedImage.accept(nil)
    }

    func removeTag(index: Int) {
        var currentTags: [TagType] = tags.value
        currentTags.remove(at: index)
        tags.accept(currentTags)
    }

    func showEditCollection() {
        self.router?.routeToAddCollection(data: editSelectedCollectionData)
    }

    func dismissAddCollection() {
        self.router?.dismissAddCollection()
    }

    func showAddTagRIB(tags: [TagType]) {
        let filteredTags = tags.filter {
            if case .addedSelectedButton = $0 {
                return true
            } else {
                return false
            }
        }
        self.router?.routeToAddTag(tags: filteredTags)
    }

    func closeAddTagView() {
        self.isHiddenDimmedView.accept(true)
        self.router?.closeAddTag()
    }

    func confirmTags(tags: [TagType]) {
        var currentTags: [TagType] = self.tags.value
        let addedTags = tags.filter { !currentTags.contains($0) }
        currentTags.append(contentsOf: addedTags)
        self.tags.accept(currentTags)
        self.closeAddTagView()
    }

    func popToRegistCollection() {
        self.listener?.popToRegistCollection()
    }

    func registCollection(collection: CollectionData, imageData: Data?) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        self.collectionUseCase.registCollection(collection: collection, imageData: imageData)
            .subscribe(onSuccess: { [weak self] _ in
                guard let self else { return }
                self.listener?.completeRegistCollection()
            }, onFailure: { error in
                print("\(self) Error: \(error)")
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: self.disposeBag)
    }

    func sendDataToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) {}

    func popToAddCollection() {}

    func closeAddCollection() {}

    func routeToRegistLocation() {}
}
