//
//  ProductsAmountToBuyDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class ShoppingListDao: DatabaseSchemaHelper {
    
    private let dbManager: DatabaseSqlManager
    static let shared = ShoppingListDao()
    
    init(dbManager: DatabaseSqlManager = .shared) {
        self.dbManager = dbManager
    }
    
    func fetchShoppingList() throws -> [ProductAmountToBuy] {
        var productsToBuy: [ProductAmountToBuy] = []
        
        let query = shoppingListTable.select(
            shoppingListTable[productId],
            shoppingListTable[amount]
        )
        
        for row in try dbManager.fetchSql(selectSql: query, tableName: Constants.productsToBuyTable) {
            
            let productId = row[shoppingListTable[productId]]
            let productToBuyAmount = row[shoppingListTable[amount]]
            
            //let product = try fetchProductById(productIdToFetch: productId!)
            let productAmount = ProductAmountToBuy(id: productId!, product: Product(id: productId), amount: productToBuyAmount!)
            
            productsToBuy.append(productAmount)
        }
        return productsToBuy
        
    }
    
    func insertProductToShoppingList(productToBuy: ProductAmountToBuy) throws -> Int? {
        let pluckSql = shoppingListTable.filter(productId == productToBuy.product.id!)

        if let existingProduct = try dbManager.pluckSql(pluckSql: pluckSql, tableName: Constants.productsToBuyTable) as? ProductAmountToBuy {
            
            let updatedAmount = existingProduct.amount + productToBuy.amount
            let updateQuery = shoppingListTable
                .filter(productId == productToBuy.product.id!)
                .update(amount <- updatedAmount)
            
            try dbManager.updateSql(updateSql: updateQuery, tableName: Constants.productsToBuyTable)
            return nil
            
        } else {
            
            let insertQuery = shoppingListTable.insert(productId <- productToBuy.product.id!,
                                                       amount <- productToBuy.amount)
            
            return try dbManager.insertSql(insertSql: insertQuery, tableName: Constants.productsToBuyTable)
        }
    }

    
    func removeAllProductsToBuy() throws {
        let deleteQueryProductToBuy = shoppingListTable.delete()
        try dbManager.deleteSql(deleteSql: deleteQueryProductToBuy, tableName: Constants.productsToBuyTable)
    }
    
    func removeProductToBuy(productToBuy: ProductAmountToBuy) throws {
        let deleteQueryProductToBuy = shoppingListTable.filter(productId == productToBuy.product.id!).delete()
        try dbManager.deleteSql(deleteSql: deleteQueryProductToBuy, tableName: Constants.productsToBuyTable)
    }
}
