import Foundation

class ProductCategory: Category, DatabaseEntity {
    
    var id: Int?
    
    init(id: Int?) {
        self.id = id
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
