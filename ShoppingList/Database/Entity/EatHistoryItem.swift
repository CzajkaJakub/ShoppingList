import Foundation
import SQLite
import UIKit

class EatHistoryItem {
    var id: Int?
    var dish: Dish?
    var dateTime: Date
    var amount: Double?
    var product: Product?
    
    init(dish: Dish?, product: Product?, amount: Double?, eatDate: Date) {
        self.id = nil
        self.dish = dish
        self.amount = amount
        self.product = product
        self.dateTime = eatDate
    }
    
    init(id: Int, dateValue: Int, dish: Dish?, product: Product?, amount: Double?) {
        self.id = id
        self.dish = dish
        self.amount = amount
        self.product = product
        self.dateTime = DateUtils.convertDoubleToDate(dateNumberValue: dateValue)
    }
    
    static var eatHistory: [EatHistoryItem] = []
    
    static func addItemToEatHistory(eatItem: EatHistoryItem) {
        do {
            try DatabaseManager.shared.insertToEatHistory(eatItem: eatItem)
            EatHistoryItem.eatHistory.append(eatItem)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func reloadEatItemsByDate(searchDate: Date) {
        do {
            EatHistoryItem.eatHistory = try DatabaseManager.shared.fetchEatHistory(dateFrom: searchDate.startOfDay, dateTo: searchDate.endOfDay)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func removeHistoryItem(historyItem: EatHistoryItem) {
        if let index = EatHistoryItem.eatHistory.firstIndex(where: { $0.id == historyItem.id }) {
            
            do {
                try DatabaseManager.shared.removeEatHistoryItem(historyItem: historyItem)
                EatHistoryItem.eatHistory.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
}
