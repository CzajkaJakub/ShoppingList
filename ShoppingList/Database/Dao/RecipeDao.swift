//
//  RecipeDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class RecipeDao: DatabaseSchemaHelper {
    
    static var loadedRecipes: [Recipe] = []
    
    
    private let dbManager: DatabaseSqlManager
    static let shared = RecipeDao()

     init(dbManager: DatabaseSqlManager = .shared) {
         self.dbManager = dbManager
     }
    
    
    static func addRecipe(recipe: Recipe) {
        
        do {
            try DatabaseManager.shared.insertRecipe(recipe: recipe)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func fetchEatItemsByDate(searchDateFrom: Date, searchDateTo: Date) {
        
        do {
            loadedRecipes = try DatabaseManager.shared.fetchRecipes(dateFrom: searchDateFrom.startOfDay, dateTo: searchDateTo.endOfDay)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func removeRecipe(recipe: Recipe) {
        
        if let index = Recipe.recipes.firstIndex(where: { $0.id == recipe.id }) {
            
            do {
                try DatabaseManager.shared.removeRecipe(recipe: recipe)
                loadedRecipes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
}
