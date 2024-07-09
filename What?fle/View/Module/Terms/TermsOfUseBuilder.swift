//
//  TermsOfUseBuilder.swift
//  What?fle
//
//  Created by 23 09 on 7/3/24.
//

import RIBs

protocol TermsOfUseDependency: Dependency {
}

final class TermsOfUseComponent: Component<TermsOfUseDependency> {
}

// MARK: - Builder

protocol TermsOfUseBuildable: Buildable {
    func build(withListener listener: TermsOfUseListener) -> TermsOfUseRouting
}

final class TermsOfUseBuilder: Builder<TermsOfUseDependency>, TermsOfUseBuildable {

    override init(dependency: TermsOfUseDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TermsOfUseListener) -> TermsOfUseRouting {
        let component = TermsOfUseComponent(dependency: dependency)
        let viewController = TermsOfUseViewController()
        let interactor = TermsOfUseInteractor(presenter: viewController)
        interactor.listener = listener
        return TermsOfUseRouter(interactor: interactor, viewController: viewController)
    }
}
