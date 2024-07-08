//
//  RegistCollectionInteractor.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

protocol RegistCollectionRouting: ViewableRouting {
    func routeToRegistCollection(data: EditSelectedCollectionData)
    func closeCurrentRIB()
}

protocol RegistCollectionPresentable: Presentable {
    var listener: RegistCollectionPresentableListener? { get set }
}

protocol RegistCollectionListener: AnyObject {}

final class RegistCollectionInteractor: PresentableInteractor<RegistCollectionPresentable>,
                                        RegistCollectionInteractable,
                                        RegistCollectionPresentableListener {
    weak var router: RegistCollectionRouting?
    weak var listener: RegistCollectionListener?

    var selectedImage: BehaviorRelay<UIImage?> = .init(value: nil)
    var tags: BehaviorRelay<[TagType]>
    let selectedLocations: BehaviorRelay<[PlaceRegistration]>
    var editSelectedCollectionData: EditSelectedCollectionData

    private let networkService: NetworkServiceDelegate

    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: RegistCollectionPresentable,
        networkService: NetworkServiceDelegate,
        data: EditSelectedCollectionData,
        tags: [RecommendHashTagModel]
    ) {
        self.networkService = networkService
        self.editSelectedCollectionData = data
        self.tags = .init(value: tags.map { .deselected($0.hashtagName) } + [.button("태그 선택")])
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

    func addImage(_ image: UIImage) {
        self.selectedImage.accept(image)
    }

    func removeImage() {
        self.selectedImage.accept(nil)
    }

    func insertTag(type: TagType) {
        var currentTags: [TagType] = tags.value
        currentTags.insert(type, at: 0)
        tags.accept(currentTags)
    }

    func remove(index: Int) {
        var currentTags: [TagType] = tags.value
        currentTags.remove(at: index)
        tags.accept(currentTags)
    }

    func showEditCollection() {
        self.router?.routeToRegistCollection(data: editSelectedCollectionData)
    }

    func closeCurrentRIB() {
        self.router?.closeCurrentRIB()
    }

    func sendDataToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) {}

    func closeAddCollection() {
        self.router?.closeCurrentRIB()
    }

    func popCurrentRIB() {}
}
