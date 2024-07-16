//
//  AddTagBuilder.swift
//  What?fle
//
//  Created by 이정환 on 7/8/24.
//

import RIBs

protocol AddTagDependency: Dependency {
    var networkService: NetworkServiceDelegate { get }
}

final class AddTagComponent: Component<AddTagDependency> {
    var networkService: NetworkServiceDelegate {
        return dependency.networkService
    }
}

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
        let component = AddTagComponent(dependency: dependency)
        let viewController = AddTagViewController()
        let interactor = AddTagInteractor(
            presenter: viewController,
            networkService: component.networkService,
            tags: tags
        )
        interactor.listener = listener
        return AddTagRouter(interactor: interactor, viewController: viewController, component: component)
    }
}
