import Foundation

enum Strings {
    case gallery
    case details
    case imagecell
    case share
    
    var value: String {
        switch self {
        case .gallery:
            return "Gallery"
        case .details:
            return "Detail"
        case .imagecell:
            return "ImageCell"
        case .share:
            return "Share"
        }
    }
}
