//
//  Nutrients.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class Nutrients {
    
    internal var calories: Double
    internal var carbo: Double
    internal var fat: Double
    internal var protein: Double

    init(cal: Double, carbo: Double, fat: Double, protein: Double) {
        self.calories = round(cal * 100) / 100.0
        self.carbo = round(carbo * 100) / 100.0
        self.fat = round(fat * 100) / 100.0
        self.protein = round(protein * 100) / 100.0
    }
    
    init(productsAmount: [ProductsAmount]) {
        self.fat = productAmounts.map {$0.product.fat * $0.amount / 100}.reduce(0, +)
        self.carbo = productAmounts.map {$0.product.carbo * $0.amount / 100}.reduce(0, +)
        self.protein = productAmounts.map {$0.product.protein * $0.amount / 100}.reduce(0, +)
        self.calories = productAmounts.map {$0.product.calories * $0.amount / 100}.reduce(0, +)
    }
}
