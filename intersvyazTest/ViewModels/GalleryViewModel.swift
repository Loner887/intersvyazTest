import Foundation
import UIKit
import RxSwift
import RxCocoa

class GalleryViewModel {

    private let coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    var allImages: [Image] = []
    var images: [Image] = []
    private let batchSize = 20
    private var isLoading = false
    private var currentPage = 0

    func transform(input: Input) -> Output {
        let navigateToDetail = input.itemSelected
            .map { [unowned self] indexPath in
                self.images[indexPath.item] 
            }
            .do(onNext: { [unowned self] image in
                self.coordinator.showDetail(image: image)
            })
        
        return Output(navigateToDetail: navigateToDetail)
    }

    func loadMoreImages(completion: @escaping () -> Void) {
        guard !isLoading else { return }
        isLoading = true

        let startIndex = currentPage * batchSize
        let endIndex = min(startIndex + batchSize, allImages.count)

        guard startIndex < endIndex else {
            isLoading = false
            completion()
            return
        }

        let newImages = Array(allImages[startIndex..<endIndex])
        images.append(contentsOf: newImages)
        currentPage += 1
        isLoading = false
        completion()
    }
}

extension GalleryViewModel {
    struct Input {
        let itemSelected: Driver<IndexPath>
    }

    struct Output {
        let navigateToDetail: Driver<Image>
    }
}
