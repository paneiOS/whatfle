//
//  AddTagInteractor.swift
//  What?fle
//
//  Created by 이정환 on 7/8/24.
//

import RIBs
import RxSwift
import RxCocoa

protocol AddTagRouting: ViewableRouting {}

protocol AddTagPresentable: Presentable {
    var listener: AddTagPresentableListener? { get set }
}

protocol AddTagListener: AnyObject {
    func confirmTags(tags: [TagType])
    func closeAddTagView()
}

final class AddTagInteractor: PresentableInteractor<AddTagPresentable>, AddTagInteractable, AddTagPresentableListener {

    weak var router: AddTagRouting?
    weak var listener: AddTagListener?

    var tags: BehaviorRelay<[TagType]>

    private let networkService: NetworkServiceDelegate
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: AddTagPresentable,
        networkService: NetworkServiceDelegate,
        tags: [TagType]
    ) {
        self.networkService = networkService
        self.tags = .init(value: tags)
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

    func addTag(type: TagType) {
        var currentTags: [TagType] = tags.value
        if !currentTags.contains(type), currentTags.count < 5 {
            currentTags.append(type)
            tags.accept(currentTags)
        }
    }

    func removeTag(index: Int) {
        var currentTags: [TagType] = tags.value
        currentTags.remove(at: index)
        tags.accept(currentTags)
    }

    func closeAddTagView() {
        listener?.closeAddTagView()
    }

    func confirmTags(tags: [TagType]) {
        listener?.confirmTags(tags: tags)
    }
}
