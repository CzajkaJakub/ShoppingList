import Foundation
import SQLite
import UIKit

class EatHistory: DatabaseEntity {
    
    var id: Int?
    var dish: Dish?
    var amount: Double
    var product: Product?
    var eatTimestamp: Double
    
    init(id: Int?) {
        self.id = id
    }
    
    convenience init(dish: Dish?, product: Product?, amount: Double, eatTimestamp: Double) {
        self.init(id: nil, dish: dish, product: product, amount: amount, eatTimestamp: eatTimestamp)
    }
    
    init(id: Int?, dish: Dish?, product: Product?, amount: Double, eatTimestamp: Double) {
        self.id = id
        self.dish = dish
        self.amount = amount
        self.product = product
        self.eatTimestamp = eatTimestamp
    }
}
