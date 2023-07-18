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
    var calories: Double
    var fat: Double
    var carbo: Double
    var proteins: Double
    var productAmounts: [ProductAmount]
    
    
    init(id: Int, name: String, photo: UIImage, calories: Double, carbo: Double, fat: Double, protein: Double, productAmounts: [ProductAmount]) {
        self.id = id
        self.name = name
        self.photo = photo.jpegData(compressionQuality: 0.8)?.toBlob()
        self.calories = calories
        self.carbo = carbo
        self.fat = fat
        self.proteins = protein
        self.productAmounts = productAmounts
    }
}


extension Data {
    func toBlob() -> Blob {
        return Blob(bytes: [UInt8](self))
    }
}
