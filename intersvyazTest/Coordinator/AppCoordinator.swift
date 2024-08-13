import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = GalleryViewModel(coordinator: self)
        let vc = GalleryViewController(viewModel: viewModel)
        vc.title = Strings.gallery.value
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showDetail(image: Image) {
        let viewModel = DetailViewModel(coordinator: self)
        let vc = DetailViewController(image: image, viewModel: viewModel) // Передаем viewModel
        vc.title = Strings.details.value
        navigationController.pushViewController(vc, animated: true)
    }
    
    func backToGallery() {
        let viewModel = GalleryViewModel(coordinator: self)
        let vc = GalleryViewController(viewModel: viewModel)
        navigationController.popViewController(animated: true) // Сброс к корневому контроллеру
    }
}
