import Foundation

class ImageService {
    static let shared = ImageService()
    var allImages: [Image] = []
    var images: [Image] = []
    private let batchSize = 20
    private var isLoading = false
    private var currentPage = 0
    
    private let baseURL = URL(string: "http://jsonplaceholder.typicode.com/photos")!
    
    func fetchImages(completion: @escaping (Result<[Image], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: baseURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let images = try decoder.decode([Image].self, from: data)
                completion(.success(images))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
