import UIKit
import SnapKit
import RxCocoa
import RxSwift

class GalleryViewController: UIViewController {
    private var collectionView: UICollectionView? 
    
    var viewModel: GalleryViewModel
    init(viewModel: GalleryViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    private let disposeBag = DisposeBag()
    var imageService = ImageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = Strings.gallery.value
        
        setupCollectionView()
        loadInitialImages()
        setupBindings()
        
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return } // Безопасное извлечение
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func loadInitialImages() {
        imageService.fetchImages { [weak self] result in
            switch result {
            case .success(let images):
                DispatchQueue.main.async {
                    self?.viewModel.allImages = images
                    self?.viewModel.loadMoreImages {
                        DispatchQueue.main.async {
                            print("Reloading collectionView")
                            self?.collectionView?.reloadData()
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch images: \(error)")
            }
        }
    }

    
    func setupBindings() {
        guard let collectionView = collectionView else { return }

        let input = GalleryViewModel.Input(itemSelected: collectionView.rx.itemSelected.asDriver())
        
        let output = viewModel.transform(input: input)
        [
            output.navigateToDetail.drive()
        ]
            .forEach({$0.disposed(by: disposeBag)})
    }

}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        let image = viewModel.images[indexPath.item]
        if let url = URL(string: image.url) {
            cell.configure(with: url)
        }

        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold: CGFloat = 100.0 // Пороговое значение для запуска подгрузки новых данных
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if contentOffsetY > contentHeight - frameHeight - threshold {
            viewModel.loadMoreImages {
                DispatchQueue.main.async {
                    self.collectionView?.reloadData() // Безопасное извлечение
                }
            }
        }
    }
}
