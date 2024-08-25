//
//  DishService.swift
//  ShoppingList
//
//  Created by Patrycja on 24/08/2024.
//

import Foundation

class DishService {
    
    static let shared = DishService()
    
    private let dishDao: DishDao
    
    var loadedDishes: [Dish] = []
    
    init(dishDao: DishDao = .shared) {
        self.dishDao = dishDao
    }
    
    func updateDish(dish: Dish){
        self.archiveDish(dish: dish)
        self.addDish(dish: dish)
    }
    
    func archiveDish(dish: Dish) {
        
        if let index = loadedDishes.firstIndex(where: { $0.id == dish.id }) {
            
            do {
                try dishDao.archiveDish(dish: dish)
                loadedDishes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    func removeDish(dish: Dish) {
        
        if let index = loadedDishes.firstIndex(where: { $0.id == dish.id }) {
            
            do {
                try dishDao.removeDish(dish: dish)
                loadedDishes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    func addDish(dish: Dish) {
        
        do {
            dish.id = try dishDao.insertDish(dish: dish)
            loadedDishes.append(dish)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func fetchDishesFromDatabase() {
        
        do {
            loadedDishes = try dishDao.fetchDishes()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
