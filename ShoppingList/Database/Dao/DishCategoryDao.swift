//
//  DishCategoryDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class DishCategoryDao: DatabaseSchemaHelper {
    
    static var loadedDishCategories: [Category] = []
    
    
    
    private let dbManager: DatabaseSqlManager
    static let shared = DishCategoryDao()

     init(dbManager: DatabaseSqlManager = .shared) {
         self.dbManager = dbManager
     }
    
    
    static func fetchDishCategoriesFromDatabase() {
        
        do {
            loadedDishCategories = try DatabaseManager.shared.fetchDishCategories()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}

