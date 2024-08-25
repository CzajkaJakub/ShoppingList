//
//  EatHistoryService.swift
//  ShoppingList
//
//  Created by jczajka on 25/08/2024.
//

import Foundation

class EatHistoryService {
    
    static let shared = EatHistoryService()
    
    private let eatHistoryDao: EatHistoryDao
    
    var loadedEatHistory: [EatHistory] = []
    
    init(eatHistoryDao: EatHistoryDao = .shared) {
        self.eatHistoryDao = eatHistoryDao
    }
    
    
    func addItemToEatHistory(eatItem: EatHistory) {
        do {
            eatItem.id = try eatHistoryDao.insertToEatHistory(eatItem: eatItem)
            loadedEatHistory.append(eatItem)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func fetchEatHistoryByDateInterval(searchDate: Date) {
        do {
            loadedEatHistory = try eatHistoryDao.fetchEatHistory(dateFrom: searchDate.startOfDay, dateTo: searchDate.endOfDay)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func removeHistoryItem(historyItem: EatHistory) {
        if let index = loadedEatHistory.firstIndex(where: { $0.id == historyItem.id }) {
            
            do {
                try eatHistoryDao.removeEatHistoryItem(historyItem: historyItem)
                loadedEatHistory.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
}
