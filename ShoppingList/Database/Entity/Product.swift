import Foundation
import UIKit
import SQLite

class Product {
    var id: Int?
    var name: String
    var photo: Blob
    var category: Category
    var weightOfPiece: Double?
    
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
    
    init(name: String, photo: UIImage, kcal: Double, carbo: Double, fat: Double, protein: Double, weightOfPiece: Double?, category: Category) {
        self.id = nil
        self.name = name
        self.photo = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
        self.category = category
        self._calories = kcal
        self._carbo = carbo
        self._fat = fat
        self._protein = protein
        self.weightOfPiece = weightOfPiece
    }
    
    init(id: Int, name: String, photo: Blob, kcal: Double, carbo: Double, fat: Double, protein: Double, weightOfPiece: Double?, category: Category) {
        self.id = id
        self.name = name
        self.photo = photo
        self.category = category
        self._calories = kcal
        self._carbo = carbo
        self._fat = fat
        self._protein = protein
        self.weightOfPiece = weightOfPiece
    }
    
    static var products: [Product] = []
    
    static func removeProduct(product: Product) {
        if let index = Product.products.firstIndex(where: { $0.id == product.id }) {
            
            do {
                try DatabaseManager.shared.removeProduct(product: product)
                Product.products.remove(at: index)
                ProductAmount.reloadProductsToBuyFromDatabase()
                Dish.reloadDishesFromDatabase()
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func addProduct(product: Product) {
        
        do {
            try DatabaseManager.shared.insertProduct(product: product)
            Product.products.append(product)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func updateProduct(product: Product) {
        if let index = Product.products.firstIndex(where: { $0.id == product.id }) {
            
            do {
                try DatabaseManager.shared.updateProduct(product: product)
                Product.products[index] = product
                Dish.reloadDishesFromDatabase()
                ProductAmount.reloadProductsToBuyFromDatabase()
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func reloadProductsFromDatabase() {
        do {
            Product.products = try DatabaseManager.shared.fetchProducts()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
