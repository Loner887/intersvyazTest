import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check if the image is already cached
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Download the image if it's not cached
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                completion(nil)
                return
            }
            
            // Cache the image
            self.cache.setObject(image, forKey: url.absoluteString as NSString)
            
            // Return the image
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
