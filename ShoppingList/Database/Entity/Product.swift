import Foundation
import UIKit
import SQLite

class Product {
    var id: Int?
    var name: String
    var photo: Blob
    var category: Category
    
    private var _calories: Double
    private var _carbo: Double
    private var _fat: Double
    private var _protein: Double
    
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
    
    init(name: String, photo: UIImage, kcal: Double, carbo: Double, fat: Double, protein: Double, category: Category) {
        self.id = nil
        self.name = name
        self.photo = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
        self.category = category
        self._calories = kcal
        self._carbo = carbo
        self._fat = fat
        self._protein = protein
    }
    
    init(id: Int, name: String, photo: Blob, kcal: Double, carbo: Double, fat: Double, protein: Double, category: Category) {
        self.id = id
        self.name = name
        self.photo = photo
        self.category = category
        self._calories = kcal
        self._carbo = carbo
        self._fat = fat
        self._protein = protein
    }
    
    static var products: [Product] = []
    
    static func removeProduct(product: Product) {
        if let index = Product.products.firstIndex(where: { $0.id == product.id }) {
            DatabaseManager.shared.removeProduct(product: product)
            Product.products.remove(at: index)
            ProductAmount.reloadProductsToBuyFromDatabase()
            Dish.reloadDishesFromDatabase()
        }
    }
    
    static func addProduct(product: Product) {
        DatabaseManager.shared.insertProduct(product: product)
        Product.products.append(product)
    }
    
    static func updateProduct(product: Product) {
        if let index = Product.products.firstIndex(where: { $0.id == product.id }) {
            Product.products[index] = product
            DatabaseManager.shared.updateProduct(product: product)
            Dish.reloadDishesFromDatabase()
            ProductAmount.reloadProductsToBuyFromDatabase()
        }
    }
    
    static func reloadProductsFromDatabase() {
        Product.products = DatabaseManager.shared.fetchProducts()
    }
}
