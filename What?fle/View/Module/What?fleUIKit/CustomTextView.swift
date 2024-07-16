//
//  CustomTextView.swift
//  What?fle
//
//  Created by JeongHwan Lee on 3/31/24.
//

import UIKit

final class CustomTextView: UIView {
    enum TextViewType {
        case basic
        case withoutTitle
        case onlyTitle

        var insets: UIEdgeInsets {
            switch self {
            case .withoutTitle:
                return UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            default:
                return UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
            }
        }

        var font: UIFont {
            switch self {
            case .withoutTitle:
                return .title20XBD
            default:
                return .body14MD
            }
        }

        var lineHeight: CGFloat {
            return 20
        }
    }

    private let titleLabel: UILabel = .init()
    private var type: TextViewType = .basic

    lazy var textView: UITextView = {
        let textView: UITextView = .init()
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = type.insets
        textView.font = type.font
        textView.contentInset = .zero
        return textView
    }()

    private let placeholdLabel: UILabel = .init()

    private let underlineView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .lineDefault
        return view
    }()

    init(type: TextViewType? = .basic) {
        super.init(frame: .zero)

        guard let type else { return }
        self.type = type
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    func setupUI() {
        textView.textContainerInset = type.insets
        textView.delegate = self

        [titleLabel, textView, placeholdLabel, underlineView].forEach {
            addSubview($0)
        }
        switch type {
        case .basic:
            titleLabel.snp.makeConstraints {
                $0.top.leading.equalToSuperview()
                $0.height.equalTo(24)
            }
            textView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(48)
            }
            placeholdLabel.snp.makeConstraints {
                $0.centerY.equalTo(textView)
                $0.leading.equalToSuperview()
            }
            underlineView.snp.makeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
        case .withoutTitle:
            textView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(48)
            }
            placeholdLabel.snp.makeConstraints {
                $0.centerY.equalTo(textView)
                $0.leading.equalToSuperview()
            }
            underlineView.snp.makeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
        case .onlyTitle:
            titleLabel.snp.makeConstraints {
                $0.top.leading.bottom.equalToSuperview()
                $0.height.equalTo(24)
            }
        }
    }

    func updateUI(title: String? = nil, isRequired: Bool = true, placehold: String = "") {
        if let title {
            titleLabel.attributedText = .makeAttributedString(
                text: title + (isRequired ? "*" : ""),
                font: .title16XBD,
                textColor: .textDefault,
                lineHeight: type.lineHeight,
                additionalAttributes: isRequired ? [(text: "*", attribute: [.foregroundColor: UIColor.red])] : nil)
        }

        placeholdLabel.attributedText = .makeAttributedString(
            text: placehold,
            font: type.font,
            textColor: .textExtralight,
            lineHeight: type.lineHeight,
            lineSpacing: 5
        )
    }
}

extension CustomTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        underlineView.backgroundColor = .Core.primary
        placeholdLabel.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        underlineView.backgroundColor = .lineDefault
        placeholdLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidChange(_ textView: UITextView) {
        switch type {
        case .basic:
            let numberOfLines = Int((textView.contentSize.height - type.lineHeight) / 17)
            textView.snp.updateConstraints {
                $0.height.equalTo(Int(type.lineHeight) * (numberOfLines >= 3 ? 3 : numberOfLines) + 28)
            }
        case .withoutTitle:
            print("textView.contentSize.height - type.lineHeight", textView.contentSize.height - type.lineHeight)
            let numberOfLines = Int((textView.contentSize.height - type.lineHeight) / 17)
            textView.snp.updateConstraints {
                $0.height.equalTo(Int(type.lineHeight) * (numberOfLines >= 2 ? 2 : numberOfLines) + 28)
            }
        default: return
        }
    }
}
