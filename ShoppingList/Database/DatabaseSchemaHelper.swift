//
//  DatabaseSchemaHelper.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class DatabaseSchemaHelper {
    
    // Tables
    internal var dishTable = Table(Constants.dishTable)
    internal var recipeTable = Table(Constants.recipeTable)
    internal var productsTable = Table(Constants.productsTable)
    internal var eatHistoryTable = Table(Constants.eatHistoryTable)
    internal var shoppingListTable = Table(Constants.productsToBuyTable)
    internal var productAmountTable = Table(Constants.productAmountTable)
    internal var dishCategoriesTable = Table(Constants.dishCategoriesTable)
    internal var productCategoriesTable = Table(Constants.productCategoriesTable)
    
    // Foreign keys columns
    internal var dishId = Expression<Int?>(Constants.dishId)
    internal var productId = Expression<Int?>(Constants.productId)
    internal var categoryId = Expression<Int>(Constants.categoryId)
    
    // Columns
    internal var id = Expression<Int>(Constants.idColumn)
    internal var fat = Expression<Double>(Constants.fatColumn)
    internal var name = Expression<String>(Constants.nameColumn)
    internal var photo = Expression<Blob>(Constants.photoColumn)
    internal var carbo = Expression<Double>(Constants.carboColumn)
    internal var amount = Expression<Double?>(Constants.amountColumn)
    internal var dateTime = Expression<Int>(Constants.dateTimeColumn)
    internal var protein = Expression<Double>(Constants.proteinColumn)
    internal var archived = Expression<Bool>(Constants.archivedColumn)
    internal var calories = Expression<Double>(Constants.caloriesColumn)
    internal var favourite = Expression<Bool>(Constants.favouriteColumn)
    internal var description = Expression<String?>(Constants.descriptionColumn)
    internal var categoryName = Expression<String>(Constants.categoryNameColumn)
    internal var weightOfPiece = Expression<Double?>(Constants.weightOfPieceColumn)
    internal var weightOfProduct = Expression<Double?>(Constants.weightOfProductColumn)
}
