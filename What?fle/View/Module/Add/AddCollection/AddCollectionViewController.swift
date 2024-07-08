//
//  AddCollectionViewController.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import RIBs
import RxCocoa
import RxSwift
import UIKit

protocol AddCollectionPresentableListener: AnyObject {
    var locationTotalCount: BehaviorRelay<Int> { get }
    var registeredLocations: BehaviorRelay<[(String, [PlaceRegistration])]> { get }
    var selectedLocations: BehaviorRelay<[(IndexPath, PlaceRegistration)]> { get }
    func closeAddCollection()
    func showRegistLocation()
    func retriveRegistLocation()
    func selectItem(with: IndexPath)
    func deselectItem(with: IndexPath)
    func showRegistCollection()
}

enum AddCollectionType {
    case limated(Int)
    case available
}

final class AddCollectionViewController: UIViewController, AddCollectionPresentable, AddCollectionViewControllable {
    private enum Constants {
        static let bottomPadding: CGFloat = 8.0
        static let maximumCount: Int = 4
    }

    weak var listener: AddCollectionPresentableListener?
    private let disposeBag = DisposeBag()

    private lazy var customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setNavigationTitle("컬렉션 생성")
        return view
    }()

    private lazy var customPresentHeader: CustomPresentHeader = {
        let view: CustomPresentHeader = .init()
        view.setHeaderTitle("컬렉션 편집")
        return view
    }()

    private let registLocationLabel: UILabel = .init()

    private lazy var limitedView: UIView = {
        let view: UIView = .init()
        let imageView: UIImageView = .init(image: .warningCircleFilled)
        imageView.tintColor = .textExtralight
        let placeholdLabel: UILabel = .init()
        placeholdLabel.numberOfLines = 2
        placeholdLabel.attributedText = .makeAttributedString(
            text: "컬렉션을 만들기 위해\n최소 4군데의 장소를 기록해야해요.",
            font: .title15RG,
            textColor: .textLight,
            lineHeight: 24,
            alignment: .center
        )
        [imageView, placeholdLabel, registLocationLabel, limitedButton].forEach {
            view.addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.size.equalTo(40)
        }
        placeholdLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
        registLocationLabel.snp.makeConstraints {
            $0.top.equalTo(placeholdLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        limitedButton.snp.makeConstraints {
            $0.top.equalTo(registLocationLabel.snp.bottom).offset(48)
            $0.centerX.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }
        return view
    }()

    private lazy var limitedButton: UIControl = {
        let control: UIControl = .init()
        control.layer.cornerRadius = 4
        control.backgroundColor = .white
        control.addShadow(
            yPoint: 2,
            blur: 10,
            color: .init(
                displayP3Red: 0,
                green: 62/255,
                blue: 135/255,
                alpha: 0.1
            )
        )
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "장소 기록하러 가기",
            font: .suit(size: 14, weight: .medium),
            textColor: .Core.approve,
            lineHeight: 20
        )
        let imageView: UIImageView = .init(image: .bright)
        [label, imageView].forEach {
            control.addSubview($0)
        }
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-4)
            $0.size.equalTo(24)
            $0.leading.equalTo(label.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().inset(8)
        }
        return control
    }()

    private lazy var selectLocationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.itemSize = .init(width: 64, height: 88)
        layout.sectionInset = UIEdgeInsets(top: 6, left: 8, bottom: 4, right: 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            SelectLocationResultCell.self,
            forCellWithReuseIdentifier: SelectLocationResultCell.reuseIdentifier
        )
        collectionView.isHidden = true
        collectionView.backgroundColor = .Core.background
        return collectionView
    }()

    private lazy var registLocationTableView: UITableView = {
        let tableView: UITableView = .init(frame: .zero, style: .grouped)
        tableView.register(SelectLocationCell.self, forCellReuseIdentifier: SelectLocationCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = .lineExtralight
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = .white
        return tableView
    }()

    var screenType: AddCollectionType = .limated(0) {
        didSet {
            switch screenType {
            case .limated(let count):
                registLocationLabel.attributedText = .makeAttributedString(
                    text: "(현재 등록장소 \(count)/4)",
                    font: .caption12BD,
                    textColor: .textExtralight,
                    lineHeight: 20
                )
                limitedView.isHidden = false
                registLocationTableView.isHidden = true
                selectLocationCollectionView.isHidden = true
            case .available:
                limitedView.isHidden = true
                registLocationTableView.isHidden = false
                selectLocationCollectionView.isHidden = false
            }
        }
    }

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewBinding()
        setupActionBinding()
        self.listener?.retriveRegistLocation()
    }

    private func setupUI() {
        view.backgroundColor = .white
        if self.navigationController != nil {
            view.addSubview(customNavigationBar)
            customNavigationBar.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(54)
            }
        } else {
            view.addSubview(customPresentHeader)
            customPresentHeader.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(54)
            }
        }

        view.addSubview(limitedView)
        limitedView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        view.addSubview(selectLocationCollectionView)
        selectLocationCollectionView.snp.makeConstraints {
            if self.navigationController != nil {
                $0.top.equalTo(customNavigationBar.snp.bottom).offset(4)
            } else {
                $0.top.equalTo(customPresentHeader.snp.bottom).offset(4)
            }
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(97)
        }

        view.addSubview(registLocationTableView)
        registLocationTableView.snp.makeConstraints {
            $0.top.equalTo(selectLocationCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(Constants.bottomPadding)
        }
    }

    private func setupViewBinding() {
        guard let listener else { return }
        listener.selectedLocations
            .bind(to: selectLocationCollectionView.rx.items(
                cellIdentifier: SelectLocationResultCell.reuseIdentifier,
                cellType: SelectLocationResultCell.self)
            ) { (_, model, cell) in
                cell.drawCell(model: model.1)
            }
            .disposed(by: disposeBag)

        listener.locationTotalCount
            .subscribe(onNext: { [weak self] count in
                guard let self else { return }
                self.screenType = count >= 4 ? .available : .limated(count)
                if count >= Constants.maximumCount {
                    self.customNavigationBar.setRightButton(title: "다음")
                }
            })
            .disposed(by: disposeBag)

        let isEnabledObservable = listener.selectedLocations.map { $0.count >= Constants.maximumCount }.share()
        isEnabledObservable
            .bind(to: customNavigationBar.rightButton.rx.isEnabled)
            .disposed(by: disposeBag)
        isEnabledObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self else { return }
                self.customNavigationBar.setRightButton(title: "저장", isEnabled: isEnabled)
            })
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.limitedButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: true)
                self.listener?.showRegistLocation()
            })
            .disposed(by: disposeBag)

        self.customNavigationBar.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: true)
                listener?.closeAddCollection()
            })
            .disposed(by: disposeBag)

        self.customNavigationBar.rightButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                listener?.showRegistCollection()
            })
            .disposed(by: disposeBag)

        self.customPresentHeader.closeButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
                listener?.closeAddCollection()
            })
            .disposed(by: disposeBag)
    }

    func reloadData() {
        self.registLocationTableView.reloadData()
    }

    private func updateSelectionOrder() {
        guard let indexPaths = listener?.selectedLocations.value.map({ $0.0 }) else { return }
        for indexPath in indexPaths {
            registLocationTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    private func retriveNextOrder(indexPath: IndexPath) -> Int {
        guard let order = self.listener?.selectedLocations.value.count else {
            return 1
        }
        return order + 1
    }

    private func retriveSelectionOrder(indexPath: IndexPath) -> Int {
        guard let order = self.listener?.selectedLocations.value.firstIndex(where: {$0.0 == indexPath}) else {
            return 0
        }
        return order + 1
    }
}

extension AddCollectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listener?.registeredLocations.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listener?.registeredLocations.value[section].1.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectLocationCell.reuseIdentifier, for: indexPath) as? SelectLocationCell,
              let model = listener?.registeredLocations.value[safe: indexPath.section]?.1[safe: indexPath.row] else {
            return UITableViewCell()
        }
        cell.drawCheckTypeCell(model: model, order: retriveSelectionOrder(indexPath: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = {
            let view: UIView = .init()
            let label: UILabel = .init()
            label.attributedText = .makeAttributedString(
                text: listener?.registeredLocations.value[section].0 ?? "",
                font: .body14MD,
                textColor: .textLight,
                lineHeight: 20
            )
            view.addSubview(label)
            label.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            return view
        }()
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}

extension AddCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === self.registLocationTableView {
            return 96
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = listener?.registeredLocations.value[safe: indexPath.section]?.1[safe: indexPath.row],
              !model.isEmptyImageURLs else {
            return
        }
        let order = retriveNextOrder(indexPath: indexPath)
        if order <= Constants.maximumCount {
            listener?.selectItem(with: indexPath)
            if let cell = registLocationTableView.cellForRow(at: indexPath) as? SelectLocationCell {
                cell.updateCheckBox(order: order)
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        listener?.deselectItem(with: indexPath)
        tableView.reloadData()
        updateSelectionOrder()
    }
}
