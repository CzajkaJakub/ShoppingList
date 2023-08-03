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
    
    static func reloadCategoriesFromDatabase() {
        Category.dishCategories = DatabaseManager.shared.fetchDishCategories()
        Category.productCategories = DatabaseManager.shared.fetchProductCategories()
    }
    
    static func reloadProductCategoriesFromDatabase() {
        Category.productCategories = DatabaseManager.shared.fetchProductCategories()
    }
    
    static func reloadDishCategoriesFromDatabase() {
        Category.dishCategories = DatabaseManager.shared.fetchDishCategories()
    }
}
