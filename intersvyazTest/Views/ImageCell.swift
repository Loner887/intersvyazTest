import UIKit

class ImageCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageCell"
    private let imageView = UIImageView()
    private var currentImageURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with url: URL) {
        currentImageURL = url
        imageView.image = nil // Очистить старое изображение

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
                // Убедиться, что URL все еще совпадает
                if self.currentImageURL == url {
                    self.imageView.image = image
                }
            }
        }
        task.resume()
    }
}


