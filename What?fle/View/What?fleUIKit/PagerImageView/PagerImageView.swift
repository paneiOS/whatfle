//
//  PagerImageView.swift
//  What?fle
//
//  Created by 이정환 on 11/30/24.
//

import UIKit

import SnapKit

protocol PagerImageViewDelegate: AnyObject {
    func pagerImageView(_ pagerImageView: PagerImageView, didSelectImageAt index: Int)
}

final class PagerImageView: UIView {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.bounces = false
        return collectionView
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .Core.primary
        pageControl.pageIndicatorTintColor = .white
        pageControl.isHidden = true
        return pageControl
    }()

    private var imageURLs: [String] = [] {
        didSet {
            self.collectionView.reloadData()
            self.pageControl.isHidden = imageURLs.count <= 1
        }
    }

    weak var delegate: PagerImageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupCollectionView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
        self.setupCollectionView()
    }

    private func setupUI() {
        self.addSubviews(collectionView, pageControl)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PagerImageCell.self, forCellWithReuseIdentifier: PagerImageCell.reuseIdentifier)
    }

    func configure(with imageURLs: [String]) {
        guard !imageURLs.isEmpty else { return }
        if imageURLs.count > 1 {
            self.imageURLs = Array(repeating: imageURLs, count: 21).flatMap { $0 }
            self.pageControl.numberOfPages = imageURLs.count
        } else {
            self.imageURLs = imageURLs
        }

        DispatchQueue.main.async {
            let middleGroupStartIndex = (self.imageURLs.count / 21) * 10
            let initialOffset = CGPoint(x: self.collectionView.frame.width * CGFloat(middleGroupStartIndex), y: 0)
            self.collectionView.setContentOffset(initialOffset, animated: false)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PagerImageView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagerImageCell.reuseIdentifier, for: indexPath) as? PagerImageCell else {
            return UICollectionViewCell()
        }
        let imageURL = imageURLs[indexPath.item]
        cell.drawCell(with: imageURL)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupSize = imageURLs.count / 21
        let realIndex = indexPath.item % groupSize
        delegate?.pagerImageView(self, didSelectImageAt: realIndex)
    }
}

// MARK: - UIScrollViewDelegate
extension PagerImageView: UIScrollViewDelegate {
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
