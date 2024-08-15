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

protocol HomePresentableListener: AnyObject {
    func showDetailCollection(id: Int)
}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {

    weak var listener: HomePresentableListener?
    private let disposeBag = DisposeBag()

    private let tempDetailButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle("컬렉션 상세보기 임시버튼", for: .normal)
        button.backgroundColor = .red
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupActionBinding()
    }

    private func setupUI() {
        self.view.addSubview(tempDetailButton)
        tempDetailButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setupActionBinding() {
        tempDetailButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // TODO: - 임시 아이디값
                let tempID: Int = 69
                self.listener?.showDetailCollection(id: tempID)
            })
            .disposed(by: disposeBag)
    }
}
