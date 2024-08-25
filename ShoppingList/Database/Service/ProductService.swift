//
//  ProductService.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class ProductService {
    
    static let shared = ProductService()

    private let productDao: ProductDao
    private let productCategoryDao: ProductCategoryDao
    
    var loadedProducts: [Product] = []
    
    init(productDao: ProductDao = .shared, productCategoryDao: ProductCategoryDao = .shared) {
        self.productDao = productDao
        self.productCategoryDao = productCategoryDao
    }
    
    func addProduct(product: Product) {
        
        do {
            product.id = try productDao.insertProduct(product: product)
            loadedProducts.append(product)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func fetchProductsFromDatabase() {
        
        do {
            loadedProducts = try productDao.fetchProducts()
            
            for fetchedProduct in loadedProducts {
                let productCategory = try productCategoryDao.fetchProductCategoryById(productCategoryId: fetchedProduct.category.id!)
                fetchedProduct.category = productCategory
            }
                        
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func fetchProductById(productId: Int) -> Product {
        
        do {
            let loadedProduct = try productDao.fetchProductById(productIdToFetch: productId)
            let productCategory = try productCategoryDao.fetchProductCategoryById(productCategoryId: loadedProduct.category.id!)
            loadedProduct.category = productCategory
            return loadedProduct
                        
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    func removeProduct(product: Product) {
        
        if let index = loadedProducts.firstIndex(where: { $0.id == product.id }) {
            
            do {
                try productDao.removeProduct(product: product)
                loadedProducts.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    func updateProduct(product: Product) {
        
        if let index = loadedProducts.firstIndex(where: { $0.id == product.id }) {
            
            do {
                try productDao.updateProduct(product: product)
                loadedProducts[index] = product
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
}
