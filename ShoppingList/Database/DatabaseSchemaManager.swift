//
//  DatabaseSchemaManager.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class DatabaseSchemaManager: DatabaseSchemaHelper {
    
    private var dbConnection: Connection
    static let shared = DatabaseSchemaManager()
    
    override private init() {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(Constants.databaseName)
        
        do {
            
            dbConnection = try Connection(fileURL.path, readonly: false)
            
            try createProductCategoriesTable()
            try createDishCategoriesTable()
            try createProductTable()
            try createDishTable()
            try createProductsToBuyTable()
            try createProductAmountTable()
            try createEatHistoryTable()
            try createRecipeTable()
            
            try insertDataIntoProductCategoriesTable()
            try insertDataIntoDishCategoriesTable()
            
        } catch {
            fatalError("\(Constants.errorCreateDatabase): \(error)")
        }
    }
    
    // ############### INSERT DATA INTO TABLES SECTION ############### //
    
    private func insertDataIntoProductCategoriesTable() throws {
        
        let selectCategoriesIfNotExists = productCategoriesTable.count
        do {
            let categoryCount = try dbConnection.scalar(selectCategoriesIfNotExists)
            
            if categoryCount == 0 {
                let categoriesSql = Constants.productCategories.map { categoryName in
                    return productCategoriesTable.insert(self.categoryName <- categoryName)
                }
                
                for query in categoriesSql {
                    do {
                        try dbConnection.run(query)
                    } catch {
                        throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productCategoriesTable)): \(error)")
                    }
                }
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productCategoriesTable)): \(error)")
        }
    }
    
    private func insertDataIntoDishCategoriesTable() throws {
        
        let selectCategoriesIfNotExists = dishCategoriesTable.count
        do {
            let categoryCount = try dbConnection.scalar(selectCategoriesIfNotExists)
            
            if categoryCount == 0 {
                let categoriesSql = Constants.dishCategories.map { categoryName in
                    return dishCategoriesTable.insert(self.categoryName <- categoryName)
                }
                
                for query in categoriesSql {
                    do {
                        try dbConnection.run(query)
                    } catch {
                        throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishCategoriesTable)): \(error)")
                    }
                }
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishCategoriesTable)): \(error)")
        }
    }
    
    // ############### CREATE TABLES SECTION ############### //
    
    private func createProductCategoriesTable() throws {
        let createCategoriesTableQuery = productCategoriesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(categoryName)
        }
        
        do {
            try dbConnection.run(createCategoriesTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productCategoriesTable)): \(error)")
        }
    }
    
    private func createDishCategoriesTable() throws {
        let createCategoriesTableQuery = dishCategoriesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(categoryName, unique: true)
        }
        
        do {
            try dbConnection.run(createCategoriesTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishCategoriesTable)): \(error)")
        }
    }
    
    private func createProductTable() throws {
        let createProductsTableQuery = productsTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(fat)
            table.column(name)
            table.column(carbo)
            table.column(photo)
            table.column(protein)
            table.column(calories)
            table.column(categoryId)
            table.column(weightOfPiece)
            table.column(weightOfProduct)
            table.foreignKey(categoryId, references: productCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductsTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productsTable)): \(error)")
        }
    }
    
    
    private func createDishTable() throws {
        let createDishTableQuery = dishTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(name)
            table.column(photo)
            table.column(archived)
            table.column(favourite)
            table.column(categoryId)
            table.column(description)
            table.foreignKey(categoryId, references: dishCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createDishTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishTable)): \(error)")
        }
    }
    
    private func createProductAmountTable() throws {
        let createProductAmountTableQuery = productAmountTable.create(ifNotExists: true) { table in
            table.column(dishId)
            table.column(productId)
            table.column(amount)
            table.foreignKey(dishId, references: dishTable, id, update: .cascade, delete: .cascade)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductAmountTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productAmountTable)): \(error)")
        }
    }
    
    private func createProductsToBuyTable() throws {
        let createProductsToBuyTableQuery = shoppingListTable.create(ifNotExists: true) { table in
            table.column(productId)
            table.column(amount)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductsToBuyTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productsToBuyTable)): \(error)")
        }
    }
    
    private func createEatHistoryTable() throws {
        let createEatHistoryTableQuery = eatHistoryTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(dateTime)
            table.column(amount, defaultValue: nil)
            table.column(productId, defaultValue: nil)
            table.column(dishId, defaultValue: nil)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
            table.foreignKey(dishId, references: dishTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createEatHistoryTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.eatHistoryTable)): \(error)")
        }
    }
    
    private func createRecipeTable() throws {
        let createRecipeTableQuery = recipeTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(dateTime)
            table.column(amount)
            table.column(photo)
        }
        
        do {
            try dbConnection.run(createRecipeTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.recipeTable)): \(error)")
        }
    }
}
