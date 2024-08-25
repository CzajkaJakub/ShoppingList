import Foundation

class DishCategory: Category, DatabaseEntity {
    
    var id: Int?
    
    init(id: Int?) {
        self.id = id
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
