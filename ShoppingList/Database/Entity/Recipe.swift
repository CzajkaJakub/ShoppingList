import Foundation
import SQLite
import UIKit

public class Recipe, DatabaseEntity {
    
    var id: Int?
    var photo: Blob
    var amount: Double
    var dateTime: Double
    
    convenience init(date: Double, amount: Double, photo: UIImage) {
        let photo = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
        self.init(id: nil, dateValue: date, amount: amount, photo: photo)
    }
    
    init(id: Int?, dateValue: Double, amount: Double, photo: Blob) {
        self.id = id
        self.photo = photo
        self.amount = amount
        self.dateTime = dateValue
    }
}
