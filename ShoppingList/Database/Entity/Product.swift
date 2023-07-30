//
//  Product.swift
//  ShoppingList
//
//  Created by Patrycja on 10/07/2023.
//

import Foundation
import UIKit
import SQLite

struct Product {
    var dbId: Int = 0
    var name: String = ""
    var photo: Blob?
    var category: Category
    
    private var _calories: Double = 0
    private var _carbo: Double = 0
    private var _fat: Double = 0
    private var _protein: Double = 0
    
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
    
    var protein: Double {
        set { _protein = newValue }
        get { return round(_protein * 100) / 100.0 }
    }
    
    init(dbId: Int, name: String, photo: UIImage, kcal: Double, carbo: Double, fat: Double, protein: Double, category: Category) {
        self.dbId = dbId
        self.name = name
        self.photo = photo.jpegData(compressionQuality: 0.8)?.toBlob()
        self.category = category
        self._calories = kcal
        self._carbo = carbo
        self._fat = fat
        self._protein = protein
    }
    
    static var products: [Product] = []
    
    static func removeProduct(product: Product) {
        if let index = Product.products.firstIndex(where: { $0.dbId == product.dbId }) {
            DatabaseManager.shared.removeProduct(product: product)
            Product.products.remove(at: index)
        }
    }
}
