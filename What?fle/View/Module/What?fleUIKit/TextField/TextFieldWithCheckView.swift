//
//  TextFieldWithCheckView.swift
//  What?fle
//
//  Created by 이정환 on 8/24/24.
//

import UIKit

import RxCocoa
import RxSwift

final class TextFieldWithCheckView: UIView {
    enum UnderlineState {
        case empty
        case valid
        case invalid
    }

    let textField: TextFieldWithErrorUnderline = {
        let textField: TextFieldWithErrorUnderline = .init()
        textField.clearButtonMode = .whileEditing
        textField.delegate = textField
        return textField
    }()

    let registButton: UIButton = {
        let button: UIButton = .init()
        button.backgroundColor = .Core.primaryDisabled
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.isEnabled = false
        return button
    }()

    private var disposeBag = DisposeBag()

    let underlineColorSubject = BehaviorSubject<UnderlineState>(value: .empty)

    private let buttonEnabledSubject = BehaviorSubject<Bool>(value: false)

    var attributedPlaceholder: NSAttributedString? {
        didSet {
            self.textField.attributedPlaceholder = attributedPlaceholder
        }
    }

    var attributedTitle: NSAttributedString? {
        didSet {
            self.registButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.makeUI()
        self.setupViewBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.makeUI()
        self.setupViewBinding()
    }

    private func makeUI() {
        addSubviews(textField, registButton)
        self.textField.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        registButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(textField.snp.trailing).offset(8)
            $0.width.equalTo(104)
            $0.height.equalTo(48)
        }
    }

    private func setupViewBinding() {
        underlineColorSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] underlineState in
                guard let self = self else { return }

                switch underlineState {
                case .empty:
                    self.textField.deactivateUnderline()
                    self.buttonEnabledSubject.onNext(false)
                case .valid:
                    self.textField.activateUnderline()
                    self.buttonEnabledSubject.onNext(true)
                case .invalid:
                    self.textField.activateErrorUnderline()
                    self.buttonEnabledSubject.onNext(false)
                }
            })
            .disposed(by: disposeBag)

        buttonEnabledSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                self.registButton.isEnabled = isEnabled
                self.registButton.backgroundColor = isEnabled ? .GrayScale.black : .Core.primaryDisabled
            })
            .disposed(by: disposeBag)
    }
}
