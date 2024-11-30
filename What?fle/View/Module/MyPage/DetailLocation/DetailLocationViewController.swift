//
//  DetailLocationViewController.swift
//  What?fle
//
//  Created by 이정환 on 11/30/24.
//

import UIKit

import RIBs
import RxSwift
import SnapKit

protocol DetailLocationPresentableListener: AnyObject {
    var detailLocationModel: HomeDataModel.Collection.Place { get }
    func popToDetailLocation()
}

final class DetailLocationViewController: UIViewController, DetailLocationPresentable, DetailLocationViewControllable {
    private enum Constants {
        static let pagerViewHeight: CGFloat = UIApplication.shared.width / 375 * 400
    }

    // MARK: - UIComponent

    private lazy var customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setNavigationTitle(buttonColor: .white)
        return view
    }()

    private let shadowView: GradientView = {
        let view: GradientView = .init(colors: [.black.withAlphaComponent(0.4), .black.withAlphaComponent(0)])
        view.isUserInteractionEnabled = false
        return view
    }()

    private let subView: UIView = {
        let view: UIView = .init()
        return view
    }()

    private let pagerImageView: PagerImageView = .init()

    private let infoView: UIView = .init()

    private let titleLabel: UILabel = .init()

    private let dateLabel: UILabel = .init()

    private let triangleView: TriangleView = .init()

    private let descriptionTextView: UITextView = {
        let view: UITextView = .init()
        view.contentInset = .init(top: 10, left: 12, bottom: 10, right: 12)
        view.backgroundColor = .Core.background
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isEditable = false
        return view
    }()

    weak var listener: DetailLocationPresentableListener?
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupData()
        self.setupActionBinding()
    }

    private func setupUI() {
        view.backgroundColor = .white

        self.view.addSubviews(self.subView, self.shadowView, self.customNavigationBar)
        self.subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        self.shadowView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }
        self.subView.addSubviews(self.pagerImageView, self.infoView)
        self.pagerImageView.snp.makeConstraints {
            $0.top.leading.trailing.width.equalToSuperview()
            $0.height.equalTo(Constants.pagerViewHeight)
        }
        self.infoView.snp.makeConstraints {
            $0.top.equalTo(self.pagerImageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        self.infoView.addSubviews(self.titleLabel, self.dateLabel, self.triangleView, self.descriptionTextView)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.dateLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        self.triangleView.snp.makeConstraints {
            $0.top.equalTo(self.dateLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(8)
            $0.width.equalTo(9)
            $0.height.equalTo(8)
        }
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.triangleView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
    }

    private func setupData() {
        guard let model = listener?.detailLocationModel else { return }
        if let imageURLs = model.imageURLs {
            self.pagerImageView.configure(with: imageURLs)
        }
        self.titleLabel.attributedText = .makeAttributedString(
            text: model.placeName,
            font: .title20XBD,
            textColor: .textDefault,
            lineHeight: 28
        )
        self.dateLabel.attributedText = .makeAttributedString(
            text: model.visitDate.replaceHyphensWithDots(),
            font: .caption13MD,
            textColor: .GrayScale.g300,
            lineHeight: 20)
        self.descriptionTextView.attributedText = .makeAttributedString(
            text: model.description,
            font: .body14RG,
            textColor: .textLight,
            lineHeight: 20
        )
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.popToDetailLocation()
            })
            .disposed(by: disposeBag)
        
        let fittingSize = CGSize(width: self.descriptionTextView.frame.width, height: 80)
        let size = self.descriptionTextView.sizeThatFits(fittingSize)
        self.descriptionTextView.snp.updateConstraints {
            $0.height.equalTo(size.height)
        }
    }
}
