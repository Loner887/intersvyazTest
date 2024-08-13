import UIKit
import RxSwift
import RxCocoa
import SnapKit

class DetailViewController: UIViewController {
    
    private let image: Image
    var viewModel: DetailViewModel
    
    private let disposeBag = DisposeBag()
    
    init(image: Image, viewModel: DetailViewModel) {
        self.image = image
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.share.value, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        configureViews()
        constraintView()
        loadImage()
        setupBindings()
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(shareButton)
    }
    
    private func constraintView() {
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func configureViews() {
        title = Strings.details.value
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.text = image.title
        
    }
    
    private func loadImage() {
        guard let url = URL(string: image.url) else { return }
        
        // Проверка кеша
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        // Асинхронная загрузка изображения с использованием URLSession
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, let image = UIImage(data: data), error == nil else {
                return
            }
            
            // Сохранение изображения в кеш
            ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        task.resume()
    }
    
    @objc private func shareImage() {
            let activityVC = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
        }
    
    func setupBindings() {
        let backButtonTap = self.rx.methodInvoked(#selector(viewWillDisappear(_:)))
                .map { _ in }
                .asDriver(onErrorDriveWith: .empty())
        let shareImage = imageView.image ?? UIImage()
        let input = DetailViewModel.Input(
            shareTrigger: shareButton.rx.tap.asDriver(),
            shareImage: Driver.just(shareImage),
            toMainPage: backButtonTap
        )
        let output = viewModel.transform(input: input)
        [
            output.toMenu.drive()
        ]
            .forEach({$0.disposed(by: disposeBag)})
    }
}

