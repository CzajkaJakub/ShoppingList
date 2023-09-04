import Foundation
import SQLite
import UIKit

enum PhotoDataError: Error {
    case conversionFailed
}

public class PhotoData {
    
    private static let targetPhotoSize = CGSize(width: 800, height: 1200)
    private static let compressionQuality = 0.7
    
    public static func convertUIImageToResizedBlob(imageToResize: UIImage) throws -> Blob {
        let resizedImage = self.resizeImage(image: imageToResize, targetSize: targetPhotoSize)
        
        guard let imageData = resizedImage?.jpegData(compressionQuality: compressionQuality) else {
            throw PhotoDataError.conversionFailed
        }
        
        var byteArray = [UInt8](repeating: 0, count: imageData.count)
        imageData.copyBytes(to: &byteArray, count: imageData.count)
        
        return Blob(bytes: byteArray)
    }
    
    public static func resizeImage(imageBlob: Blob, targetSize: CGSize) -> UIImage? {
        let photoData = Data.fromDatatypeValue(imageBlob)
        return resizeImage(image: UIImage(data: photoData)!, targetSize: targetSize)
    }
    
    public static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public static func blobToUIImage(photoBlob: Blob) -> UIImage {
        let photoData = Data.fromDatatypeValue(photoBlob)
        return UIImage(data: photoData)!
    }
}
