//
//  FoodFactsService.swift
//  ShoppingList
//
//  Created by jczajka on 17/08/2024.
//

import Foundation

public struct ProductDto: Codable {
    let product: ProductInfo
    
    enum CodingKeys: String, CodingKey {
        case product
    }
}

struct ProductInfo: Codable {
    let nutriments: Nutriments?
    let productName: String?
    let productQuantity: String?
    let image: String?
    let imageIngredients: String?
    
    enum CodingKeys: String, CodingKey {
        case nutriments
        case productName = "product_name"
        case productQuantity = "product_quantity"
        case image = "image_url"
        case imageIngredients = "image_ingredients_url"
    }
}

struct Nutriments: Codable {
    let carbohydrates100g: Double?
    let energyKcal100g: Double?
    let fat100g: Double?
    let proteins100g: Double?
    
    enum CodingKeys: String, CodingKey {
        case carbohydrates100g = "carbohydrates_100g"
        case energyKcal100g = "energy-kcal_100g"
        case fat100g = "fat_100g"
        case proteins100g = "proteins_100g"
    }
}
