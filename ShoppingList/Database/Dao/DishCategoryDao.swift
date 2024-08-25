//
//  DishCategoryDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class DishCategoryDao: DatabaseSchemaHelper {
    
    private let dbManager: DatabaseSqlManager
    static let shared = DishCategoryDao()
    
    init(dbManager: DatabaseSqlManager = .shared) {
        self.dbManager = dbManager
    }
    
    func fetchDishCategories() throws -> [DishCategory] {
        var categories: [DishCategory] = []
        
        var selectQuery = dishCategoriesTable
            .select(
                dishCategoriesTable[id],
                dishCategoriesTable[categoryName]
            ).order(dishCategoriesTable[categoryName])
        
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.dishCategoriesTable) {
            let categoryId = row[dishCategoriesTable[id]]
            let categoryName = row[dishCategoriesTable[categoryName]]
            
            let category = DishCategory(id: categoryId, name: categoryName)
            categories.append(category)
        }
        return categories
    }
    
    func fetchDishCategoryById(dishCategoryToFetch: Int) throws -> DishCategory {
        var category: DishCategory!
        
        let selectQuery = dishCategoriesTable
            .select(
                dishCategoriesTable[id],
                dishCategoriesTable[categoryName]
            ).filter(dishCategoriesTable[id] == dishCategoryToFetch)
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.dishCategoriesTable) {
            let categoryId = row[dishCategoriesTable[id]]
            let categoryName = row[dishCategoriesTable[categoryName]]
            
            category = DishCategory(id: categoryId, name: categoryName)
        }
        return category
    }
}
