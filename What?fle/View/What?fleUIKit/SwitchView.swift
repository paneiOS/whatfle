//
//  SwitchView.swift
//  What?fle
//
//  Created by 이정환 on 5/17/24.
//

import SnapKit
import UIKit

final class SwitchView: UIView {
    private let label: UILabel = .init()

    lazy var switchControl: UISwitch = {
        let control: UISwitch = .init()
        control.onTintColor = .Core.primary
        control.addTarget(self, action: #selector(onClickSwitch(sender:)), for: .valueChanged)
        return control
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func draw(title: String) {
        label.attributedText = .makeAttributedString(
            text: title,
            font: .title16MD,
            textColor: .textDefault,
            lineHeight: 24
        )
    }

    func makeUI() {
        self.addSubviews(label, switchControl)

        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        self.switchControl.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(52)
        }
    }

    @objc private func onClickSwitch(sender: UISwitch) {
        switchControl.isOn.toggle()
    }
}
