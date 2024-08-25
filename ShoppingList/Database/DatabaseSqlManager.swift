import Foundation
import SQLite
import SQLite3
import UIKit

class DatabaseSqlManager: DatabaseSchemaHelper {
    
    private var dbConnection: Connection
    static let shared = DatabaseSqlManager()
    
    override private init() {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(Constants.databaseName)
        
        print(fileURL)
        
        do {
            dbConnection = try Connection(fileURL.path, readonly: false)
        } catch {
            fatalError("\(error)")
        }
    }
    
    
    
    // ############### FETCHING SECTION ############### //
    
    
    
    
    
    func fetchProductsForDish(dishIdToSearch: Int) throws -> [ProductAmount] {
        var productAmountsForDish: [ProductAmount] = []
        
        let productsForDishQuery = productAmountTable
            .select(
                productAmountTable[productId],
                productAmountTable[amount]
            )
            .filter(productAmountTable[dishId] == dishIdToSearch)
        
        do {
            for productRow in try dbConnection.prepare(productsForDishQuery) {
                
                let productId = productRow[productAmountTable[productId]]
                let productAmount = productRow[productAmountTable[amount]]
                let product = try fetchProductById(productIdToFetch: productId!)
                
                let productAmountForDish = ProductAmount(product: product, amount: productAmount!)
                productAmountsForDish.append(productAmountForDish)
            }
            return productAmountsForDish
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.productForDish)): \(error)")
        }
    }
    
    
    
    
    
    
    
    func insertProductAmountForDish(dish: Dish) throws {
        do {
            for productAmount in dish.productAmounts {
                let insertProductAmountQuery = productAmountTable.insert(
                    self.dishId <- Int(dish.id!),
                    self.productId <- productAmount.product.id!,
                    self.amount <- productAmount.amount
                )
                try dbConnection.run(insertProductAmountQuery)
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(Constants.productAmount)): \(error)")
        }
    }
    
    
    
    
    func removeProductAmountForDish(dish: Dish) throws {
        let deleteProductAmountQuery = productAmountTable.filter(dishId == dish.id!).delete()
        
        do {
            try dbConnection.run(deleteProductAmountQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.productAmount)): \(error)")
        }
    }
    
    
    
    
    
    
    
    
    
    func updateSql(updateSql: Update, tableName: String) throws {
        do {
            try dbConnection.run(updateSql)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorUpdate) (\(tableName)): \(error)")
        }
    }
    
    func fetchSql(selectSql: Table, tableName: String) throws -> [Row] {
        var results: [Row] = []
        
        do {
            for row in try dbConnection.prepare(selectSql) {
                results.append(row)
            }
            
            return results
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(tableName)): \(error)")
        }
    }
    
    func insertSql(insertSql: Insert, tableName: String) throws -> Int {
        do {
            return try Int(dbConnection.run(insertSql))
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(tableName)): \(error)")
        }
    }
    
    func deleteSql(deleteSql: Delete, tableName: String) throws {
        do {
            try dbConnection.run(deleteSql)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(tableName)): \(error)")
        }
    }
    
    func pluckSql(pluckSql: Table, tableName: String) throws -> Optional<DatabaseEntity> {
        do {
            return try dbConnection.pluck(pluckSql)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(tableName)): \(error)")
        }
    }
}
