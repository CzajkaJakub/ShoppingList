//
//  Category.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation

class Category {
    
    var id: Int?
    var name: String?
    
    convenience init(id: Int) {
        self.init(id: id, name: nil)
    }
    
    convenience init(name: String) {
        self.init(id: nil, name: name)
    }
    
    init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }
}
