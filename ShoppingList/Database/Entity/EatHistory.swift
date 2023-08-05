import Foundation
import SQLite
import UIKit

class EatHistory {
    var id: Int?
    var dateTime: Date
    var amount: Double?
    var product: Product?
    var dish: Dish?
    
    init(dateTime: Date, amount: Double?, product: Product?, dish: Dish?) {
        self.id = nil
        self.dateTime = dateTime
        self.amount = amount
        self.product = product
        self.dish = dish
    }
    
    
    init(id: Int, dateTime: Int, amount: Double?, product: Product?, dish: Dish?) {
        self.id = id
        self.amount = amount
        self.product = product
        self.dish = dish
        let timeInterval = TimeInterval(dateTime)
        let myNSDate = Date(timeIntervalSince1970: timeInterval)
        self.dateTime = myNSDate
    }
    
    static var eatHistory: [EatHistory] = []
    
    static func addItemToEatHistory(eatItem: EatHistory) {
        DatabaseManager.shared.insertToEatHistory(eatItem: eatItem)
        EatHistory.eatHistory.append(eatItem)
    }
}
