//
//  AddViewController.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import UIKit

import RIBs
import RxCocoa
import RxSwift
import SnapKit

protocol AddPresentableListener: AnyObject {
    func showRegistLocation()
    func showAddCollection()
    func closeView()
}

final class AddViewController: UIViewController, AddPresentable, AddViewControllable {

    weak var listener: AddPresentableListener?

    private let disposeBag = DisposeBag()

    private let dimmedView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .Core.dimmed20
        view.isHidden = true
        return view
    }()

    private let contentView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let registLocationControl: UIControl = {
        let control: UIControl = .init()
        let subView: UIView = {
            let view: UIView = .init()
            view.isUserInteractionEnabled = false
            let imageView: UIImageView = {
                let view: UIImageView = .init()
                view.image = .addLocation
                return view
            }()
            let label: UILabel = {
                let label: UILabel = .init()
                label.text = "장소 기록하기"
                label.font = .title16MD
                label.textColor = .textDefault
                return label
            }()
            view.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.size.equalTo(40)
            }
            view.addSubview(label)
            label.snp.makeConstraints {
                $0.leading.equalTo(imageView.snp.trailing).offset(10)
                $0.centerY.equalTo(imageView)
            }
            return view
        }()
        control.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return control
    }()

    private let addCollectionControl: UIControl = {
        let control: UIControl = .init()
        let subView: UIView = {
            let view: UIView = .init()
            view.isUserInteractionEnabled = false
            let imageView: UIImageView = {
                let view: UIImageView = .init()
                view.image = .addCollection
                return view
            }()
            let label: UILabel = {
                let label: UILabel = .init()
                label.text = "컬렉션 만들기"
                label.font = .title16MD
                label.textColor = .textDefault
                return label
            }()
            view.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.size.equalTo(40)
            }
            view.addSubview(label)
            label.snp.makeConstraints {
                $0.leading.equalTo(imageView.snp.trailing).offset(10)
                $0.centerY.equalTo(imageView)
            }
            return view
        }()
        control.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return control
    }()

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupTapGesture()
        self.setupViewBinding()
        self.setupActionBinding()
    }
}

extension AddViewController {
    private func setupUI() {
        self.view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(256)
        }

        self.contentView.addSubview(registLocationControl)
        registLocationControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(80)
        }

        self.contentView.addSubview(addCollectionControl)
        addCollectionControl.snp.makeConstraints {
            $0.top.equalTo(registLocationControl.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(80)
        }
    }

    private func setupViewBinding() {
        self.rx.viewWillAppear
            .take(1)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.dimmedView.isHidden = false
            })
            .disposed(by: disposeBag)

        self.rx.viewWillDisappear
            .take(1)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.dimmedView.isHidden = true
            })
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        registLocationControl.rx.controlEvent(.touchUpInside).bind { [weak self] in
            guard let self else { return }
            listener?.showRegistLocation()
        }
        .disposed(by: disposeBag)

        addCollectionControl.rx.controlEvent(.touchUpInside).bind { [weak self] in
            guard let self else { return }
            listener?.showAddCollection()
        }
        .disposed(by: disposeBag)
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        self.dimmedView.addGestureRecognizer(tapGesture)
    }

    @objc func dimmedViewTapped() {
        self.dimmedView.isHidden = true
        listener?.closeView()
    }
}
