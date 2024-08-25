//
//  RecipeService.swift
//  ShoppingList
//
//  Created by jczajka on 25/08/2024.
//

import Foundation

class RecipeService {
    
    static let shared = RecipeService()
    
    private let recipeDao: RecipeDao
    
    var loadedRecipes: [Recipe] = []
    
    init(recipeDao: RecipeDao = .shared) {
        self.recipeDao = recipeDao
    }
    
    func addRecipe(recipe: Recipe) {
        
        do {
            recipe.id = try recipeDao.insertRecipe(recipe: recipe)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func fetchEatItemsByDate(searchDateFrom: Date, searchDateTo: Date) {
        
        do {
            loadedRecipes = try recipeDao.fetchRecipes(dateFrom: searchDateFrom.startOfDay, dateTo: searchDateTo.endOfDay)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func removeRecipe(recipe: Recipe) {
        
        if let index = loadedRecipes.firstIndex(where: { $0.id == recipe.id }) {
            
            do {
                try recipeDao.removeRecipe(recipe: recipe)
                loadedRecipes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
}
