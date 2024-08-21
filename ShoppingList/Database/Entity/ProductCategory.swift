import Foundation

class Category {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.id = nil
        self.name = name
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    static var productCategories: [Category] = []
    static var dishCategories: [Category] = []
    
    static func reloadProductCategoriesFromDatabase() {
        do {
            Category.productCategories = try DatabaseManager.shared.fetchProductCategories()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func reloadDishCategoriesFromDatabase() {
        do {
            Category.dishCategories = try DatabaseManager.shared.fetchDishCategories()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
