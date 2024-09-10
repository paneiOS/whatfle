//
//  HomeViewController.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import RxCocoa
import RxSwift
import UIKit

protocol HomePresentableListener: AnyObject {}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {
    weak var listener: HomePresentableListener?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupActionBinding()
    }

    private func setupUI() {}

    private func setupActionBinding() {}
}
