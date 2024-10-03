//
//  TotalSearchBarBuilder.swift
//  What?fle
//
//  Created by 이정환 on 10/1/24.
//

import RIBs

protocol TotalSearchBarDependency: Dependency {
    var totalSearchUseCase: TotalSearchUseCaseProtocol { get }
}

final class TotalSearchBarComponent: Component<TotalSearchBarDependency> {
    var totalSearchUseCase: TotalSearchUseCaseProtocol {
        return dependency.totalSearchUseCase
    }
}

// MARK: - Builder

protocol TotalSearchBarBuildable: Buildable {
    func build(withListener listener: TotalSearchBarListener) -> TotalSearchBarRouting
}

final class TotalSearchBarBuilder: Builder<TotalSearchBarDependency>, TotalSearchBarBuildable {

    override init(dependency: TotalSearchBarDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TotalSearchBarListener) -> TotalSearchBarRouting {
        let component = TotalSearchBarComponent(dependency: dependency)
        let viewController = TotalSearchBarViewController()
        let interactor = TotalSearchBarInteractor(
            presenter: viewController,
            totalSearchUseCase: component.totalSearchUseCase
        )
        interactor.listener = listener
        return TotalSearchBarRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
    }
}
