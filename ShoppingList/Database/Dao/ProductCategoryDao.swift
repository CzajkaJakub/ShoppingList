//
//  ProductCategoryDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class ProductCategoryDao: DatabaseSchemaHelper {
    
    private let dbManager: DatabaseSqlManager
    static let shared = ProductCategoryDao()
    
    init(dbManager: DatabaseSqlManager = .shared) {
        self.dbManager = dbManager
    }
    
    func fetchProductCategories() throws -> [ProductCategory] {
        var categories: [ProductCategory] = []
        
        let selectQuery = productCategoriesTable
            .select(
                productCategoriesTable[id],
                productCategoriesTable[categoryName]
            ).order(productCategoriesTable[categoryName])
        
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.productCategoriesTable) {
            let categoryId = row[productCategoriesTable[id]]
            let categoryName = row[productCategoriesTable[categoryName]]
            
            let category = ProductCategory(id: categoryId, name: categoryName)
            categories.append(category)
        }
        
        return categories
    }
    
    func fetchProductCategoryById(productCategoryId: Int) throws -> ProductCategory {
        
        let selectQuery = productCategoriesTable
            .select(
                productCategoriesTable[id],
                productCategoriesTable[categoryName]
            ).filter(productCategoriesTable[id] == productCategoryId)
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.productCategoriesTable) {
            let categoryId = row[productCategoriesTable[id]]
            let categoryName = row[productCategoriesTable[categoryName]]
            
            return ProductCategory(id: categoryId, name: categoryName)
        }
    }
}

