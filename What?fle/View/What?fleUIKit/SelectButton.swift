//
//  SelectButton.swift
//  What?fle
//
//  Created by 이정환 on 9/22/24.
//

import UIKit

import RxCocoa
import RxSwift

final class SelectButton: UIButton {
    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfigure()
        setupActionBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfigure()
        setupActionBinding()
    }

    private func setupConfigure() {
        self.setImage(.selectOff, for: .normal)
        self.setImage(.selectOn, for: .selected)
        var config = UIButton.Configuration.plain()
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.contentInsets = .zero
        config.background.backgroundColor = .clear
        self.configuration = config
    }

    private func setupActionBinding() {
        self.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isSelected.toggle()
            })
            .disposed(by: disposeBag)
    }
}
