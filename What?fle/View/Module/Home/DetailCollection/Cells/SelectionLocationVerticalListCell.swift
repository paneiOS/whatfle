//
//  SelectionLocationVerticalListCell.swift
//  What?fle
//
//  Created by 이정환 on 8/12/24.
//

import Kingfisher
import RxSwift
import RxCocoa
import UIKit

protocol SelectionLocationVerticalListCellDelegate: AnyObject {
    func cell(_ cell: SelectionLocationVerticalListCell, didUpdateHeight height: CGFloat, at index: Int)
}

final class SelectionLocationVerticalListCell: UICollectionViewCell {
    private enum Constants {
        enum Height {
            static let pagerCollectionViewHeight: CGFloat = UIApplication.shared.width / 375 * 400
            static let placeInfoViewHeight: CGFloat = 96
            static let profileViewMinumHeight: CGFloat = 56
        }
        static let interPadding: CGFloat = 16
    }
    static let reuseIdentifier = "SelectionLocationVerticalListCell"

    weak var delegate: SelectionLocationVerticalListCellDelegate?

    private lazy var pagerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PagerImageCell.self, forCellWithReuseIdentifier: PagerImageCell.reuseIdentifier)
        collectionView.contentInset = .zero
        collectionView.scrollIndicatorInsets = .zero
        collectionView.alwaysBounceHorizontal = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.bounces = false
        return collectionView
    }()

    private let placeInfoView: UIView = .init()

    private let placeImage: UIImageView = {
        let view: UIImageView = .init()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lineExtralight.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.font = .body14SB
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .caption12RG
        label.textColor = .textExtralight
        return label
    }()

    private let favoriteButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.favoriteOff, for: .normal)
        return button
    }()

    private let profileView: UIView = .init()

    private let profileImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()

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

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .Core.primary
        pageControl.pageIndicatorTintColor = .white
        pageControl.isUserInteractionEnabled = false
        pageControl.isHidden = true
        return pageControl
    }()

    private var model: PublishSubject<PlaceRegistration> = .init()
    private var imageURLs: [String] = [] {
        didSet {
            self.pagerCollectionView.reloadData()
        }
    }
    var index: Int?

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        bindUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
        bindUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageURLs.removeAll()
        pageControl.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if pagerCollectionView.contentOffset == .zero, imageURLs.count > 21 {
            let middleGroupStartIndex = (imageURLs.count / 21) * 10
            let initialOffset = CGPoint(x: pagerCollectionView.frame.width * CGFloat(middleGroupStartIndex), y: 0)
            pagerCollectionView.setContentOffset(initialOffset, animated: false)
        }
    }

    private func setupUI() {
        [self.pagerCollectionView, self.pageControl, self.placeInfoView, self.profileView].forEach {
            contentView.addSubview($0)
        }
        self.pagerCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.width.equalToSuperview()
            $0.height.equalTo(Constants.Height.pagerCollectionViewHeight)
        }
        self.pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.placeInfoView.snp.top).offset(-16)
        }
        [self.placeImage, self.titleLabel, self.subTitleLabel, self.favoriteButton].forEach {
            self.placeInfoView.addSubview($0)
        }
        self.placeInfoView.snp.makeConstraints {
            $0.top.equalTo(self.pagerCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(Constants.Height.placeInfoViewHeight)
        }
        self.placeImage.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(64)
        }
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeImage.snp.top)
            $0.leading.equalTo(self.placeImage.snp.trailing).offset(8)
        }
        self.subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(self.placeImage.snp.trailing).offset(8)
            $0.bottom.equalTo(self.placeImage.snp.bottom)
        }
        self.favoriteButton.snp.makeConstraints {
            $0.top.equalTo(self.placeImage.snp.top)
            $0.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(32)
        }
        [self.profileImageView, self.triangleView, self.descriptionTextView].forEach {
            self.profileView.addSubview($0)
        }
        self.profileView.snp.makeConstraints {
            $0.top.equalTo(self.placeInfoView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(Constants.Height.profileViewMinumHeight)
        }
        self.profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(24)
        }
        self.triangleView.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom)
            $0.leading.equalToSuperview().inset(8)
            $0.width.equalTo(9)
            $0.height.equalTo(8)
        }
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.triangleView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }

    private func bindUI() {
        model.subscribe(onNext: { [weak self] place in
            guard let self else { return }
            if let placeImageURLs = place.imageURLs {
                if placeImageURLs.count < 2 {
                    self.imageURLs = placeImageURLs
                } else {
                    self.imageURLs = Array(repeating: placeImageURLs, count: 21).flatMap { $0 }
                    self.pageControl.numberOfPages = place.imageURLs?.count ?? 0
                    self.pageControl.isHidden = false
                }
            }

            self.placeImage.image = place.categoryGroupCode.image
            self.titleLabel.attributedText = .makeAttributedString(
                text: place.placeName,
                font: .body14SB,
                textColor: .textDefault,
                lineHeight: 20
            )
            self.subTitleLabel.attributedText = .makeAttributedString(
                text: place.roadAddress,
                font: .caption13MD,
                textColor: .textExtralight,
                lineHeight: 20
            )
            self.profileImageView.image = .placehold
            self.descriptionTextView.attributedText = .makeAttributedString(
                text: place.description,
                font: .body14RG,
                textColor: .textLight,
                lineHeight: 20
            )
            let profileViewHeight = place.description.isEmpty ? 0 : Constants.Height.profileViewMinumHeight + descriptionTextView.attributedText.height(containerWidth: UIApplication.shared.width - 56) + 20
            self.profileView.isHidden = profileViewHeight == 0
            self.profileView.snp.updateConstraints {
                $0.height.equalTo(profileViewHeight)
            }
            if let index = self.index {
                self.updateTotalHeight(profileViewHeight: profileViewHeight, at: index)
            }
        }).disposed(by: disposeBag)
    }

    func drawCell(model: PlaceRegistration, at index: Int) {
        self.index = index
        self.model.onNext(model)
    }
}

extension SelectionLocationVerticalListCell {
    private func updateTotalHeight(profileViewHeight: CGFloat, at index: Int) {
        let totalHeight: CGFloat = Constants.Height.pagerCollectionViewHeight + Constants.Height.placeInfoViewHeight + profileViewHeight + Constants.interPadding
        delegate?.cell(self, didUpdateHeight: totalHeight, at: index)
    }
}

extension SelectionLocationVerticalListCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagerImageCell.reuseIdentifier, for: indexPath) as? PagerImageCell else {
            return UICollectionViewCell()
        }
        let imageURLStr = self.imageURLs[indexPath.item]
        cell.drawCell(with: imageURLStr)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: Constants.Height.pagerCollectionViewHeight)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        let groupSize = imageURLs.count / 21
        let itemIndex = currentPage % groupSize
        self.pageControl.currentPage = itemIndex
        if groupSize * 10 > currentPage || groupSize * 11 <= currentPage {
            let targetIndex = groupSize * 10 + itemIndex
            let newOffset = CGPoint(x: scrollView.frame.width * CGFloat(targetIndex), y: scrollView.contentOffset.y)
            scrollView.setContentOffset(newOffset, animated: false)
        }
    }
}
