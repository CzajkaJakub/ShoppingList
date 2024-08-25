//
//  ProductCategoryService.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class ProductCategoryService {
    
    static let shared = ProductCategoryService()

    private let productCategoryDao: ProductCategoryDao
    
    var loadedProductCategories: [ProductCategory] = []

    init(productCategoryDao: ProductCategoryDao = .shared) {
        self.productCategoryDao = productCategoryDao
    }
    
    func fetchProductCategoriesFromDatabase() {
        
        do {
            loadedProductCategories = try productCategoryDao.fetchProductCategories()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
