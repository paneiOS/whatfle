//
//  FavoriteButton.swift
//  What?fle
//
//  Created by 이정환 on 9/21/24.
//

import UIKit

import RxCocoa
import RxSwift

final class FavoriteButton: UIButton {

    private let disposeBag = DisposeBag()

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.setImage(.Icon.favoriteOn, for: .selected)
            } else {
                self.setImage(.Icon.favoriteOff, for: .selected)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(.Icon.favoriteOff, for: .normal)
        self.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.isSelected.toggle()
            })
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setImage(.Icon.favoriteOff, for: .normal)
        self.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.isSelected.toggle()
            })
            .disposed(by: disposeBag)
    }
}
