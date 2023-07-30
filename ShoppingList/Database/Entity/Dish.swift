//
//  Dish.swift
//  ShoppingList
//
//  Created by Patrycja on 15/07/2023.
//

import Foundation
import SQLite
import UIKit

struct Dish {
    var id: Int
    var photo: Blob?
    var name: String
    var productAmounts: [ProductAmount]
    var category: Category
    
    private var _calories: Double = 0
    private var _carbo: Double = 0
    private var _fat: Double = 0
    private var _proteins: Double = 0
    
    var calories: Double {
        set { _calories = newValue }
        get { return round(_calories * 100) / 100.0 }
    }
    
    var carbo: Double {
        set { _carbo = newValue }
        get { return round(_carbo * 100) / 100.0 }
    }
    
    var fat: Double {
        set { _fat = newValue }
        get { return round(_fat * 100) / 100.0 }
    }
    
    var proteins: Double {
        set { _proteins = newValue }
        get { return round(_proteins * 100) / 100.0 }
    }
    
    init(id: Int, name: String, photo: UIImage, calories: Double, carbo: Double, fat: Double, protein: Double, productAmounts: [ProductAmount], category: Category) {
        self.id = id
        self.name = name
        self.photo = photo.jpegData(compressionQuality: 0.8)?.toBlob()
        self.category = category
        self.productAmounts = productAmounts
        self._calories = calories
        self._carbo = carbo
        self._fat = fat
        self._proteins = protein
    }
    
    init(name: String, photo: UIImage, productAmounts: [ProductAmount], category: Category) {
        self.id = 0
        self.name = name
        self.photo = photo.jpegData(compressionQuality: 0.8)?.toBlob()
        self.category = category
        self.productAmounts = productAmounts
        self._calories = productAmounts.map {$0.product.calories * $0.amount / 100}.reduce(0, +)
        self._carbo = productAmounts.map {$0.product.carbo * $0.amount / 100}.reduce(0, +)
        self._fat = productAmounts.map {$0.product.fat * $0.amount / 100}.reduce(0, +)
        self._proteins = productAmounts.map {$0.product.protein * $0.amount / 100}.reduce(0, +)
    }
    
    static var dishes: [Dish] = []
    
    static func removeDish(dish: Dish) {
        if let index = Dish.dishes.firstIndex(where: { $0.id == dish.id }) {
            DatabaseManager.shared.removeDish(dish: dish)
            Dish.dishes.remove(at: index)
        }
    }
    
    static func addDish(dish: Dish) {
        DatabaseManager.shared.insertDish(dish: dish)
        Dish.dishes.append(dish)
    }
}


extension Data {
    func toBlob() -> Blob {
        return Blob(bytes: [UInt8](self))
    }
}



