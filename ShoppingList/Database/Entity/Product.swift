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
    var kcal: Double = 0
    var carbo: Double = 0
    var fat: Double = 0
    var protein: Double = 0
    var category: Category

    init(dbId: Int, name: String, photo: UIImage, kcal: Double, carbo: Double, fat: Double, protein: Double, category: Category) {
        self.dbId = dbId
        self.name = name
        self.photo = photo.jpegData(compressionQuality: 0.8)?.toBlob()
        self.kcal = kcal
        self.carbo = carbo
        self.fat = fat
        self.protein = protein
        self.category = category
    }
}
