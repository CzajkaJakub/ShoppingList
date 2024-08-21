//
//  ProductsAmountToBuyDao.swift
//  ShoppingList
//
//  Created by Patrycja on 21/08/2024.
//

import Foundation

class ProductAmountToBuyDao {
    
    static var loadedProductsToBuy: [ProductAmountToBuy] = []
    
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
            addProductTuBuy(productAmount: productAmount)
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
