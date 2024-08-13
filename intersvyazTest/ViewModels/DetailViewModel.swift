import Foundation
import UIKit
import RxSwift
import RxCocoa

class DetailViewModel: BaseViewModel {
    
    private let coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        let shareTrigger = input.shareTrigger
        let shareImage = input.shareImage
        
        let toMenu = input.toMainPage
            .do(onNext: { [unowned self] in
                self.coordinator.backToGallery()
            })
        
        return Output(toMenu: toMenu)
    }
}

extension DetailViewModel {
    struct Input {
        let shareTrigger: Driver<Void>
        let shareImage: Driver<UIImage>
        let toMainPage: Driver<Void>
    }
    
    struct Output {
        let toMenu: Driver<Void>
    }
}
