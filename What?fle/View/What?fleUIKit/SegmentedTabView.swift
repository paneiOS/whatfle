//
//  SegmentedTabView.swift
//  What?fle
//
//  Created by 이정환 on 12/1/24.
//

import UIKit

import SnapKit

final class SegmentedTabView: UIView {
    private let stackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let lineView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .Core.primary
        return view
    }()

    var onTabSelected: ((Int) -> Void)?
    var initialIndex: Int = 0 {
        didSet {
            self.updateTabSelection(self.initialIndex, animated: false)
        }
    }

    private var titles: [String] = []
    private var buttons: [UIButton] = []
    private var lineViewLeadingConstraint: Constraint?
    private var isInitialSetupCompleted = false

    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInitialSetupCompleted {
            self.updateTabSelection(self.initialIndex, animated: false)
            isInitialSetupCompleted = true
        }
    }

    private func setupUI() {
        for (index, title) in self.titles.enumerated() {
            let button: UIButton = .init()
            button.setAttributedTitle(
                .makeAttributedString(
                    text: title,
                    font: .title15XBD,
                    textColor: .textDefault,
                    lineHeight: 24
                ),
                for: .selected
            )
            button.setAttributedTitle(
                .makeAttributedString(
                    text: title,
                    font: .title15SB,
                    textColor: .textExtralight,
                    lineHeight: 24
                ),
                for: .normal
            )
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            if index == self.initialIndex {
                button.isSelected = true
            }
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        self.addSubviews(self.stackView, self.lineView)
        self.stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.lineView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(3)
            $0.width.equalToSuperview().dividedBy(self.titles.count)
            self.lineViewLeadingConstraint = $0.leading.equalToSuperview().constraint
        }
    }

    @objc private func tabButtonTapped(_ sender: UIButton) {
        let selectedIndex = sender.tag
        self.updateTabSelection(selectedIndex, animated: true)
        onTabSelected?(selectedIndex)
    }

    func updateTabSelection(_ index: Int, animated: Bool) {
        for (buttonIndex, button) in buttons.enumerated() {
            button.isSelected = buttonIndex == index
        }
        guard self.bounds.width > 0 else { return }
        let buttonWidth = self.bounds.width / CGFloat(self.titles.count)
        let newLeading = CGFloat(index) * buttonWidth
        self.lineViewLeadingConstraint?.update(offset: newLeading)
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
}
