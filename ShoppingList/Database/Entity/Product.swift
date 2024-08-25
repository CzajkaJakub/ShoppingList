import Foundation
import UIKit
import SQLite

class Product: Nutrients, DatabaseEntity {
    
    var id: Int?
    var photo: Blob
    var name: String
    var weightOfPiece: Double?
    var weightOfProduct: Double?
    var category: ProductCategory
    
    init(id: Int?) {
        self.id = id
    }
    
    init(name: String, photo: UIImage, kcal: Double, carbo: Double, fat: Double, protein: Double, weightOfPiece: Double?, weightOfProduct: Double?, category: ProductCategory) {
        self.name = name
        self.category = category
        self.weightOfPiece = weightOfPiece
        self.weightOfProduct = weightOfProduct
        self.photo = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
        super.init(cal: kcal, carbo: carbo, fat: fat, protein: protein)
    }
    
    init(id: Int?, name: String, photo: Blob, kcal: Double, carbo: Double, fat: Double, protein: Double, weightOfPiece: Double?, weightOfProduct: Double?, category: ProductCategory) {
        self.id = id
        self.name = name
        self.photo = photo
        self.category = category
        self.weightOfPiece = weightOfPiece
        self.weightOfProduct = weightOfProduct
        super.init(cal: kcal, carbo: carbo, fat: fat, protein: protein)
    }
}
