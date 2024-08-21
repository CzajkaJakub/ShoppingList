import Foundation
import SQLite
import UIKit

class Dish: Nutrients, DatabaseEntity {
    
    var id: Int?
    var photo: Blob
    var name: String
    var archived: Bool
    var favourite: Bool
    var category: Category
    var description: String?
    var productAmounts: [DishProductAmount]
    
    convenience init(name: String, description: String?, photo: UIImage, archived: Bool, productAmounts: [DishProductAmount], category: Category) {
        let photo = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
        self.init(id: nil, name: name, description: description, favourite: false, photo: photo, archived: archived, productAmounts: productAmounts, category: category)
    }
    
    init(id: Int?, name: String, description: String?, favourite: Bool, photo: Blob, archived: Bool, productAmounts: [DishProductAmount], category: Category) {
        self.id = id
        self.name = name
        self.photo = photo
        self.category = category
        self.favourite = favourite
        self.archived = archived
        self.description = description
        self.productAmounts = productAmounts
        super.init(productsAmount: productAmounts)
    }
}
