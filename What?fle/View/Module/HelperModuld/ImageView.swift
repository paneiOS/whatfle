//
//  ImageView.swift
//  What?fle
//
//  Created by 이정환 on 9/22/24.
//

import UIKit

import Nuke

final class ImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = .placehold
    }

    init() {
        super.init(frame: .zero)
        self.image = .placehold
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.image = .placehold
    }

    static let sharedPipeline: ImagePipeline = {
        let memoryCache = ImageCache()
        memoryCache.costLimit = 50 * 1024 * 1024 // 50MB 메모리 캐시

        let dataCache = try? DataCache(name: "com.Whatfle.What-fle")
        dataCache?.sizeLimit = 100 * 1024 * 1024 // 100MB 디스크 캐시

        return ImagePipeline {
            $0.imageCache = memoryCache
            $0.dataCache = dataCache
        }
    }()

    func loadImage(from urlStr: String?, placeholder: UIImage? = nil) {
        guard let urlStr else { return }
        if let placeholder {
            self.image = placeholder
        }
        let url = URL(string: urlStr)
        let request = ImageRequest(url: url)
        ImageView.sharedPipeline.loadImage(with: request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.image = response.image
            case .failure: return
            }
        }
    }
}
