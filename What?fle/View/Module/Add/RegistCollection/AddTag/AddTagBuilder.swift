//
//  AddTagBuilder.swift
//  What?fle
//
//  Created by 이정환 on 7/8/24.
//

import RIBs

protocol AddTagDependency: Dependency {}

final class AddTagComponent: Component<AddTagDependency> {}

extension AddTagComponent: AddTagDependency {
    var addTagBuilder: AddTagBuildable {
        return AddTagBuilder(dependency: self)
    }
}

// MARK: - Builder

protocol AddTagBuildable: Buildable {
    func build(withListener listener: AddTagListener, tags: [TagType]) -> AddTagRouting
}

final class AddTagBuilder: Builder<AddTagDependency>, AddTagBuildable {

    override init(dependency: AddTagDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: AddTagListener, tags: [TagType]) -> AddTagRouting {
        let viewController = AddTagViewController()
        let interactor = AddTagInteractor(
            presenter: viewController,
            tags: tags
        )
        interactor.listener = listener
        return AddTagRouter(interactor: interactor, viewController: viewController)
    }
}
