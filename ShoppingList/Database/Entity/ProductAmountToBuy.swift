//
//  ProductsToBuy.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class ProductAmountToBuy: ProductsAmount, DatabaseEntity {
    
    var id: Int?
    
    init(id: Int) {
        self.id = id
    }
    
    init(id: Int, product: Product, amount: Double) {
        self.id = id
        super.init(product: product, amount: amount)
    }
}
