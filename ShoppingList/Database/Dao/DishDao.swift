//
//  DishDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class DishDao: DatabaseSchemaHelper {
    
    static var loadedDishes: [Dish] = []
    
    
    
    private let dbManager: DatabaseSqlManager
    static let shared = DishDao()

     init(dbManager: DatabaseSqlManager = .shared) {
         self.dbManager = dbManager
     }
    
    
    static func updateDish(dish: Dish){
        self.archiveDish(dish: dish)
        self.addDish(dish: dish)
    }
    
    static func archiveDish(dish: Dish) {
        
        if let index = loadedDishes.firstIndex(where: { $0.id == dish.id }) {
            
            do {
                try DatabaseManager.shared.archiveDish(dish: dish)
                loadedDishes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func removeDish(dish: Dish) {
        
        if let index = loadedDishes.firstIndex(where: { $0.id == dish.id }) {
            
            do {
                try DatabaseManager.shared.removeDish(dish: dish)
                loadedDishes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func addDish(dish: Dish) {
        
        do {
            try DatabaseManager.shared.insertDish(dish: dish)
            loadedDishes.append(dish)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func fetchDishesFromDatabase() {
        
        do {
            loadedDishes = try DatabaseManager.shared.fetchDishes()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
