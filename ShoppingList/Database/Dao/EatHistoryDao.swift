//
//  EatHistoryDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class EatHistoryDao: DatabaseSchemaHelper {
    
    private let dbManager: DatabaseSqlManager
    static let shared = EatHistoryDao()
    
    init(dbManager: DatabaseSqlManager = .shared) {
        self.dbManager = dbManager
    }
    
    func fetchEatHistory(dateFrom: Date, dateTo: Date) throws -> [EatHistory] {
        var eatHistory: [EatHistory] = []
        
        let selectQuery = eatHistoryTable
            .select(eatHistoryTable[*])
            .filter(eatHistoryTable[dateTime] >= DateUtils.convertDateToDoubleValue(dateToConvert: dateFrom) &&
                    eatHistoryTable[dateTime] <= DateUtils.convertDateToDoubleValue(dateToConvert: dateTo))
            .order(eatHistoryTable[dateTime])
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.eatHistoryTable) {
            let eatHistoryId = row[eatHistoryTable[id]]
            let dateTime = row[eatHistoryTable[dateTime]]
            let productId = row[eatHistoryTable[productId]]
            let dishId = row[eatHistoryTable[dishId]]
            let amount = row[eatHistoryTable[amount]]
            
            eatHistory.append(EatHistory(id: eatHistoryId, dish: Dish(id: dishId), product: Product(id: productId), amount: amount!, eatTimestamp: dateTime))
        }
        
        return eatHistory
    }
    
    
    func insertToEatHistory(eatItem: EatHistory) throws -> Int {
        let insertEatItemQuery = eatHistoryTable.insert(
            dateTime <- eatItem.eatTimestamp,
            amount <- eatItem.amount,
            productId <- eatItem.product?.id,
            dishId <- eatItem.dish?.id
        )
        
        return try Int(dbManager.insertSql(insertSql: insertEatItemQuery, tableName: Constants.eatHistoryTable))
    }
    
    func removeEatHistoryItem(historyItem: EatHistory) throws {
        let deleteQueryEatHistoryItem = eatHistoryTable.filter(id == historyItem.id!).delete()
        try dbManager.deleteSql(deleteSql: deleteQueryEatHistoryItem, tableName: Constants.eatHistoryTable)
    }
}
