//
//  DishProductAmount.swift
//  ShoppingList
//
//  Created by Patrycja on 21/08/2024.
//

import Foundation

class DishProductAmount: ProductsAmount, DatabaseEntity {
    
    var id: Int?
    
    init(id: Int) {
        self.id = id
    }
    
    
    init(id: Int, product: Product, amount: Double) {
        self.id = id
        super.init(product: product, amount: amount)
    }
}
