import Foundation
import SQLite
import UIKit

class EatHistoryItem {
    var id: Int?
    var dateTime: Date
    var productAmount: ProductAmount?
    var dish: Dish?
    
    init(dish: Dish) {
        self.id = nil
        self.dateTime = Date.now
        self.productAmount = nil
        self.dish = dish
    }
    
    init(productAmount: ProductAmount) {
        self.id = nil
        self.dateTime = Date.now
        self.productAmount = productAmount
        self.dish = nil
    }
    
    init(id: Int, dateValue: Int, productAmount: ProductAmount) {
        self.id = id
        self.productAmount = productAmount
        self.dish = nil
        self.dateTime = DateUtils.convertDoubleToDate(dateNumberValue: dateValue)
    }
    
    init(id: Int, dateValue: Int, dish: Dish) {
        self.id = id
        self.productAmount = nil
        self.dish = dish
        self.dateTime = DateUtils.convertDoubleToDate(dateNumberValue: dateValue)
    }
    
    static var eatHistory: [EatHistoryItem] = []
    
    static func addItemToEatHistory(eatItem: EatHistoryItem) {
        DatabaseManager.shared.insertToEatHistory(eatItem: eatItem)
        EatHistoryItem.eatHistory.append(eatItem)
    }
    
    static func reloadEatItemsByDate(searchDate: Date) {
        EatHistoryItem.eatHistory = DatabaseManager.shared.fetchEatHistory(dateFrom: searchDate.startOfDay, dateTo: searchDate.endOfDay)
    }
    
    static func removeHistoryItem(historyItem: EatHistoryItem) {
        if let index = EatHistoryItem.eatHistory.firstIndex(where: { $0.id == historyItem.id }) {
            DatabaseManager.shared.removeEatHistoryItem(historyItem: historyItem)
            EatHistoryItem.eatHistory.remove(at: index)
        }
    }
}
