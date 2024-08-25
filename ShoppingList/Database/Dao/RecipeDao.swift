//
//  RecipeDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class RecipeDao: DatabaseSchemaHelper {
    
    private let dbManager: DatabaseSqlManager
    static let shared = RecipeDao()

     init(dbManager: DatabaseSqlManager = .shared) {
         self.dbManager = dbManager
     }
    
    func insertRecipe(recipe: Recipe) throws -> Int {
        let insertRecipeQuery = recipeTable.insert(
            dateTime <- recipe.dateTime,
            amount <- recipe.amount,
            photo <- recipe.photo
        )
        
        return try dbManager.insertSql(insertSql: insertRecipeQuery, tableName: Constants.recipeTable)
    }
    
    
    func removeRecipe(recipe: Recipe) throws {
        let deleteQuery = recipeTable.filter(id == recipe.id!).delete()
        try dbManager.deleteSql(deleteSql: deleteQuery, tableName: Constants.recipeTable)
    }
    
    
    func fetchRecipes(dateFrom: Date, dateTo: Date) throws -> [Recipe] {
        var recipes: [Recipe] = []
        
        let selectQuery = recipeTable
            .select(recipeTable[*])
            .filter(recipeTable[dateTime] >= DateUtils.convertDateToDoubleValue(dateToConvert: dateFrom) &&
                    recipeTable[dateTime] <= DateUtils.convertDateToDoubleValue(dateToConvert: dateTo))
            .order(recipeTable[dateTime])
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.recipeTable) {
            let recipeId = row[recipeTable[id]]
            let dateTime = row[recipeTable[dateTime]]
            let amount = row[recipeTable[amount]]
            let photo = row[recipeTable[photo]]
            
            let recipe = Recipe(id: recipeId, dateValue: dateTime, amount: amount!, photo: photo)
            recipes.append(recipe)
        }
        return recipes
    }
}
