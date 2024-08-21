//
//  ProductsAmount.swift
//  ShoppingList
//
//  Created by Patrycja on 21/08/2024.
//

import Foundation

class ProductsAmount: NSCopying {
    
    var amount: Double
    var product: Product
    
    init(product: Product, amount: Double) {
        self.amount = amount
        self.product = product
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copyPA = ProductsAmount(product: self.product, amount: self.amount)
        return copyPA
    }
}
