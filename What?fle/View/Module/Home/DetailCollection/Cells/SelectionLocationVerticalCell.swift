//
//  SelectionLocationVerticalCell.swift
//  What?fle
//
//  Created by 이정환 on 8/8/24.
//

import RxSwift
import RxCocoa
import UIKit

protocol SelectionLocationVerticalCellDelegate: AnyObject {
    func cell(_ cell: SelectionLocationVerticalCell, didUpdateHeight height: CGFloat)
    func updateFavoriteLocation(id: Int, isFavorite: Bool)
}

final class SelectionLocationVerticalCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectionLocationVerticalCell"

    weak var delegate: SelectionLocationVerticalCellDelegate?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 24
        layout.minimumLineSpacing = 24
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SelectionLocationVerticalListCell.self, forCellWithReuseIdentifier: SelectionLocationVerticalListCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    private let placesRelay = BehaviorRelay<[PlaceRegistration]>(value: [])
    private let disposeBag = DisposeBag()
    private var cellHeights: [Int: CGFloat] = [:]

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

    private func setupUI() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func bindUI() {
        self.placesRelay
            .bind(to: collectionView.rx.items(
                    cellIdentifier: SelectionLocationVerticalListCell.reuseIdentifier,
                    cellType: SelectionLocationVerticalListCell.self
                )) { index, place, cell in
                    cell.delegate = self
                    cell.drawCell(model: place, at: index)
            }
            .disposed(by: disposeBag)
    }

    func drawCell(places: [PlaceRegistration]) {
        placesRelay.accept(places)
        collectionView.layoutIfNeeded()
    }
}

extension SelectionLocationVerticalCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = cellHeights[indexPath.item] ?? 512
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

extension SelectionLocationVerticalCell: SelectionLocationVerticalListCellDelegate {
    func cell(_ cell: SelectionLocationVerticalListCell, didUpdateHeight height: CGFloat, at index: Int) {
        cellHeights[index] = height
        let totalHeight = cellHeights.values.reduce(0, +) + CGFloat(cellHeights.count + 1) * 24.0
        self.delegate?.cell(self, didUpdateHeight: totalHeight)
    }

    func didTapFavoriteLocation(id: Int, isFavorite: Bool) {
        self.delegate?.updateFavoriteLocation(id: id, isFavorite: isFavorite)
    }
}
