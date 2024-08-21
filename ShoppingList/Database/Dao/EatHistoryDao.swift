//
//  EatHistoryDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class EatHistoryDao: DatabaseSchemaHelper {
    
    static var loadedEatHistory: [EatHistory] = []
    
    
    
    private let dbManager: DatabaseSqlManager
    static let shared = EatHistoryDao()

     init(dbManager: DatabaseSqlManager = .shared) {
         self.dbManager = dbManager
     }
    
    
    static func addItemToEatHistory(eatItem: EatHistory) {
        do {
            try DatabaseManager.shared.insertToEatHistory(eatItem: eatItem)
            loadedEatHistory.append(eatItem)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func fetchEatHistoryByDateInterval(searchDate: Date) {
        do {
            loadedEatHistory = try DatabaseManager.shared.fetchEatHistory(dateFrom: searchDate.startOfDay, dateTo: searchDate.endOfDay)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func removeHistoryItem(historyItem: EatHistory) {
        if let index = loadedEatHistory.firstIndex(where: { $0.id == historyItem.id }) {
            
            do {
                try DatabaseManager.shared.removeEatHistoryItem(historyItem: historyItem)
                loadedEatHistory.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
}
