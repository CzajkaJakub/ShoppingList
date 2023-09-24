import Foundation
import SQLite
import UIKit

class Dish {
    var id: Int?
    var photo: Blob
    var name: String
    var archived: Bool
    var favourite: Bool
    var category: Category
    var description: String?
    var amountOfPortion: Double?
    var productAmounts: [ProductAmount]
    
    private var _fat: Double
    private var _carbo: Double
    private var _calories: Double
    private var _proteins: Double
    
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
    
    init(name: String, description: String?, photo: UIImage, archived: Bool, amountOfPortion: Double?, productAmounts: [ProductAmount], category: Category) {
        self.id = nil
        self.name = name
        self.name = name
        self.favourite = false
        self.category = category
        self.archived = archived
        self.description = description
        self.productAmounts = productAmounts
        self.amountOfPortion = amountOfPortion
        self.photo = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
        self._fat = productAmounts.map {$0.product.fat * $0.amount / 100}.reduce(0, +)
        self._carbo = productAmounts.map {$0.product.carbo * $0.amount / 100}.reduce(0, +)
        self._proteins = productAmounts.map {$0.product.protein * $0.amount / 100}.reduce(0, +)
        self._calories = productAmounts.map {$0.product.calories * $0.amount / 100}.reduce(0, +)
    }
    
    init(id: Int, name: String, description: String?, favourite: Bool, photo: Blob, archived: Bool, amountOfPortion: Double?, productAmounts: [ProductAmount], category: Category) {
        self.id = id
        self.name = name
        self.photo = photo
        self.category = category
        self.favourite = favourite
        self.archived = archived
        self.description = description
        self.productAmounts = productAmounts
        self.amountOfPortion = amountOfPortion
        self._fat = productAmounts.map {$0.product.fat * $0.amount / 100}.reduce(0, +)
        self._carbo = productAmounts.map {$0.product.carbo * $0.amount / 100}.reduce(0, +)
        self._proteins = productAmounts.map {$0.product.protein * $0.amount / 100}.reduce(0, +)
        self._calories = productAmounts.map {$0.product.calories * $0.amount / 100}.reduce(0, +)
    }
    
    static var dishes: [Dish] = []
    
    static func removeDish(dish: Dish) {
        if let index = Dish.dishes.firstIndex(where: { $0.id == dish.id }) {
            
            do {
                try DatabaseManager.shared.removeDish(dish: dish)
                Dish.dishes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func addDish(dish: Dish) {
        
        do {
            try DatabaseManager.shared.insertDish(dish: dish)
            Dish.dishes.append(dish)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func archiveDish(dish: Dish) {
        if let index = Dish.dishes.firstIndex(where: { $0.id == dish.id }) {
            
            do {
                try DatabaseManager.shared.archiveDish(dish: dish)
                Dish.dishes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func updateDish(dish: Dish){
        Dish.archiveDish(dish: dish)
        Dish.addDish(dish: dish)
    }
    
    static func reloadDishesFromDatabase() {
        
        do {
            Dish.dishes = try DatabaseManager.shared.fetchDishes()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
