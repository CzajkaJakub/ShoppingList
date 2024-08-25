//
//  DishDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class DishDao: DatabaseSchemaHelper {
    
    static var loadedDishes: [Dish] = []
    
    private let dbManager: DatabaseSqlManager
    static let shared = DishDao()
    
    init(dbManager: DatabaseSqlManager = .shared) {
        self.dbManager = dbManager
    }
    
    func removeDish(dish: Dish) throws {
        let deleteQueryDish = dishTable.filter(id == dish.id!).delete()
        return try dbManager.deleteSql(deleteSql: deleteQueryDish, tableName: Constants.dish)
    }
    
    func insertDish(dish: Dish) throws -> Int {
        
        let insertDishQuery = dishTable.insert(
            name <- dish.name,
            photo <- dish.photo,
            archived <- dish.archived,
            favourite <- dish.favourite,
            categoryId <- dish.category.id!,
            description <- dish.description)
        
        return try dbManager.insertSql(insertSql: insertDishQuery, tableName: Constants.dish)
        
//            try insertProductAmountForDish(dish: dish)
     
    }
    
    func fetchDishes() throws -> [Dish] {
        var dishes: [Dish] = []
        
            let dishFetchQuery = dishTable.select(dishTable[*]).filter(dishTable[archived] == false).order(dishTable[name])
            
            for dishRow in try dbManager.fetchSql(selectSql: dishFetchQuery, tableName: Constants.dish) {
                
                let dishId = dishRow[dishTable[id]]
                let dishName = dishRow[dishTable[name]]
                let dishPhoto = dishRow[dishTable[photo]]
                let archived = dishRow[dishTable[archived]]
                let dishFavourite = dishRow[dishTable[favourite]]
                let dishCategoryId = dishRow[dishTable[categoryId]]
                let dishDescription = dishRow[dishTable[description]]
                
//                let dishCategory = try fetchDishCategoryById(dishCategoryToFetch: dishCategoryId)
//                let productAmountsForDish = try fetchProductsForDish(dishIdToSearch: dishId)
                
                dishes.append(Dish(id: dishId, name: dishName, description: dishDescription, favourite: dishFavourite, photo: dishPhoto, archived: archived, productAmounts: [], category: DishCategory(id: dishCategoryId)))
            }

        return dishes
    }
    
    func fetchDishById(dishIdToFetch: Int) throws -> Dish {

        let dishFetchQuery = dishTable.select(dishTable[*]).filter(dishTable[id] == dishIdToFetch)
        
        for dishRow in try! dbManager.fetchSql(selectSql: dishFetchQuery, tableName: Constants.dishTable) {
            let dishId = dishRow[dishTable[id]]
            let dishName = dishRow[dishTable[name]]
            let dishPhoto = dishRow[dishTable[photo]]
            let archived = dishRow[dishTable[archived]]
            let dishFavourite = dishRow[dishTable[favourite]]
            let dishCategoryId = dishRow[dishTable[categoryId]]
            let dishDescription = dishRow[dishTable[description]]
            
            //                let dishCategory = try fetchDishCategoryById(dishCategoryToFetch: dishCategoryId)
            //                let productAmountsForDish = try fetchProductsForDish(dishIdToSearch: dishId)
            
            return Dish(id: dishId, name: dishName, description: dishDescription, favourite: dishFavourite, photo: dishPhoto, archived: archived, productAmounts: [], category: DishCategory(id: dishCategoryId))
        }
    }
    
    func archiveDish(dish: Dish) throws {
        
        let archiveDishQuery = dishTable.filter(id == dish.id!)
            .update(archived <- true)
        
        try dbManager.updateSql(updateSql: archiveDishQuery, tableName: Constants.dishTable)
    }
    
    func updateDish(dish: Dish) throws {
        
        let updateDishQuery = dishTable.filter(id == dish.id!)
            .update(name <- dish.name,
                    photo <- dish.photo,
                    archived <- dish.archived,
                    favourite <- dish.favourite,
                    categoryId <- dish.category.id!,
                    description <- dish.description)
        
        try dbManager.updateSql(updateSql: updateDishQuery, tableName: Constants.dishTable)
//        try removeProductAmountForDish(dish: dish)
//        try insertProductAmountForDish(dish: dish)
    }
}
