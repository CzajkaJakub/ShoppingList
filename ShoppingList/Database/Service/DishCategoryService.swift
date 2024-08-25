//
//  DishCategoryService.swift
//  ShoppingList
//
//  Created by jczajka on 25/08/2024.
//

import Foundation

class DishCategoryService {
    
    static let shared = DishCategoryService()

    private let dishCategoryDao: DishCategoryDao
    
    var loadedDishCategories: [DishCategory] = []

    init(dishCategoryDao: DishCategoryDao = .shared) {
        self.dishCategoryDao = dishCategoryDao
    }
    
    func fetchDishCategoriesFromDatabase() {
        
        do {
            loadedDishCategories = try dishCategoryDao.fetchDishCategories()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
