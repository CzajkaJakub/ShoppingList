//
//  ShoppingListService.swift
//  ShoppingList
//
//  Created by jczajka on 25/08/2024.
//

import Foundation

class ShoppingListService {
    
    static let shared = ShoppingListService()
    
    private let dishCategoryDao: DishCategoryDao
    
    var loadedProductsToBuy: [ProductAmountToBuy] = []
    
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
    
    static func removeProductToBuy(productToBuy: ProductAmountToBuy) {
        
        if let index = loadedProductsToBuy.firstIndex(where: { $0.product.id == productToBuy.product.id }) {
            
            do {
                try DatabaseManager.shared.removeProductToBuy(productToBuy: productToBuy)
                loadedProductsToBuy.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func clearShoppingList() {
        do {
            try DatabaseManager.shared.removeAllProductsToBuy()
            loadedProductsToBuy.removeAll()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func addProductToBuy(dish: Dish) {
        for productAmount in dish.productAmounts {
            let productToBuy = ProductAmountToBuy(product: productAmount.product, amount: productAmount.amount)
            addProductTuBuy(productAmount: productToBuy)
        }
    }
    
    static func addProductTuBuy(productAmount: ProductAmountToBuy) {
        do {
            try DatabaseManager.shared.insertProductToShoppingList(productToBuy: productAmount)
            if let existingProductAmountIndex = loadedProductsToBuy.firstIndex(where: { $0.product.id == productAmount.product.id }) {
                loadedProductsToBuy[existingProductAmountIndex].amount += productAmount.amount
            } else {
                loadedProductsToBuy.append(productAmount)
            }
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func fetchroductsToBuyFromDatabase() {
        do {
            loadedProductsToBuy = try DatabaseManager.shared.fetchShoppingList()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
}
