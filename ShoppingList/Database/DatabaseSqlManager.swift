import Foundation
import SQLite
import SQLite3
import UIKit

class DatabaseManager {
    
    static let shared = DatabaseManager()
    private var dbConnection: Connection
    
    
    
        // ############### UPDATE SECTION ############### //
    

    
    func archiveDish(dish: Dish) throws {
        
        do {
            let archiveDishQuery = dishTable.filter(id == dish.id)
                .update(archived <- true)
            
            try dbConnection.run(archiveDishQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorArchive) (\(Constants.dish)): \(error)")
        }
    }
    
    func updateDish(dish: Dish) throws {
        do {
            if let _ = try dbConnection.pluck(dishTable.filter(id == dish.id)) {
                
                let updateDishQuery = dishTable.filter(id == dish.id)
                    .update(name <- dish.name,
                            photo <- dish.photo,
                            archived <- dish.archived,
                            favourite <- dish.favourite,
                            categoryId <- dish.category.id,
                            description <- dish.description)
                
                try dbConnection.run(updateDishQuery)
                try removeProductAmountForDish(dish: dish)
                try insertProductAmountForDish(dish: dish)
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorUpdate) (\(Constants.dish)): \(error)")
        }
    }
    
    // ############### FETCHING SECTION ############### //
    
    func fetchRecipes(dateFrom: Date, dateTo: Date) throws -> [Recipe] {
        var recipes: [Recipe] = []
        
        let selectQuery = recipeTable
            .select(recipeTable[*])
            .filter(recipeTable[dateTime] >= DateUtils.convertDateToIntValue(dateToConvert: dateFrom) &&
                    recipeTable[dateTime] <= DateUtils.convertDateToIntValue(dateToConvert: dateTo))
            .order(recipeTable[dateTime])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let recipeId = row[recipeTable[id]]
                let dateTime = row[recipeTable[dateTime]]
                let amount = row[recipeTable[amount]]
                let photo = row[recipeTable[photo]]
                
                let recipe = Recipe(id: recipeId, dateValue: dateTime, amount: amount!, photo: photo)
                recipes.append(recipe)
            }
            return recipes
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.recipe)): \(error)")
        }
    }
    
    func fetchEatHistory(dateFrom: Date, dateTo: Date) throws -> [EatHistory] {
        var eatHistory: [EatHistory] = []
        
        let selectQuery = eatHistoryTable
            .select(eatHistoryTable[*])
            .filter(eatHistoryTable[dateTime] >= DateUtils.convertDateToIntValue(dateToConvert: dateFrom) &&
                    eatHistoryTable[dateTime] <= DateUtils.convertDateToIntValue(dateToConvert: dateTo))
            .order(eatHistoryTable[dateTime])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let eatHistoryId = row[eatHistoryTable[id]]
                let dateTime = row[eatHistoryTable[dateTime]]
                let productId = row[eatHistoryTable[productId]]
                let dishId = row[eatHistoryTable[dishId]]
                let amount = row[eatHistoryTable[amount]]
                
                let eatHistoryItem: EatHistory!
                
                if productId != nil {
                    let product = try fetchProductById(productIdToFetch: productId!)
                    eatHistoryItem = EatHistory(id: eatHistoryId, dateValue: dateTime, dish: nil, product: product, amount: amount!)
                } else if dishId != nil {
                    let dish = try fetchDishById(dishIdToFetch: dishId!)
                    eatHistoryItem = EatHistory(id: eatHistoryId, dateValue: dateTime, dish: dish, product: nil, amount: amount!)
                } else {
                    throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.eatHistory)): rekord historii nie ma idDish oraz idProduct")
                }
                
                eatHistory.append(eatHistoryItem)
            }
            return eatHistory
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.eatHistory)): \(error)")
        }
    }
    
    func fetchDishes() throws -> [Dish] {
        var dishes: [Dish] = []
        do {
            let dishFetchQuery = dishTable.select(dishTable[*]).filter(dishTable[archived] == false).order(dishTable[name])
            
            for dishRow in try dbConnection.prepare(dishFetchQuery) {
                let dishId = dishRow[dishTable[id]]
                let dishName = dishRow[dishTable[name]]
                let dishPhoto = dishRow[dishTable[photo]]
                let archived = dishRow[dishTable[archived]]
                let dishFavourite = dishRow[dishTable[favourite]]
                let dishCategoryId = dishRow[dishTable[categoryId]]
                let dishDescription = dishRow[dishTable[description]]
                let amountOfPortion = dishRow[dishTable[amountOfPortion]]
                
                let dishCategory = try fetchDishCategoryById(dishCategoryToFetch: dishCategoryId)
                let productAmountsForDish = try fetchProductsForDish(dishIdToSearch: dishId)
                
                dishes.append(Dish(id: dishId, name: dishName, description: dishDescription, favourite: dishFavourite, photo: dishPhoto, archived: archived, amountOfPortion: amountOfPortion, productAmounts: productAmountsForDish, category: dishCategory))
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.dish)): \(error)")
        }
        return dishes
    }
    
    func fetchDishById(dishIdToFetch: Int) throws -> Dish {
        var dish: Dish!
        let dishFetchQuery = dishTable.select(dishTable[*]).filter(dishTable[id] == dishIdToFetch)
        
        do {
            for dishRow in try! dbConnection.prepare(dishFetchQuery) {
                let dishId = dishRow[dishTable[id]]
                let dishName = dishRow[dishTable[name]]
                let dishPhoto = dishRow[dishTable[photo]]
                let archived = dishRow[dishTable[archived]]
                let dishFavourite = dishRow[dishTable[favourite]]
                let dishCategoryId = dishRow[dishTable[categoryId]]
                let dishDescription = dishRow[dishTable[description]]
                let amountOfPortion = dishRow[dishTable[amountOfPortion]]
                
                let productAmountsForDish = try fetchProductsForDish(dishIdToSearch: dishId)
                let dishCategory = try fetchDishCategoryById(dishCategoryToFetch: dishCategoryId)
                
                dish = Dish(id: dishId, name: dishName, description: dishDescription, favourite: dishFavourite, photo: dishPhoto, archived: archived, amountOfPortion: amountOfPortion, productAmounts: productAmountsForDish, category: dishCategory)
            }
            return dish
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.dish)): \(error)")
        }
    }
    
    func fetchProductsForDish(dishIdToSearch: Int) throws -> [ProductAmount] {
        var productAmountsForDish: [ProductAmount] = []
        
        let productsForDishQuery = productAmountTable
            .select(
                productAmountTable[productId],
                productAmountTable[amount]
            )
            .filter(productAmountTable[dishId] == dishIdToSearch)
        
        do {
            for productRow in try dbConnection.prepare(productsForDishQuery) {
                
                let productId = productRow[productAmountTable[productId]]
                let productAmount = productRow[productAmountTable[amount]]
                let product = try fetchProductById(productIdToFetch: productId!)
                
                let productAmountForDish = ProductAmount(product: product, amount: productAmount!)
                productAmountsForDish.append(productAmountForDish)
            }
            return productAmountsForDish
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.productForDish)): \(error)")
        }
    }
    
    func fetchShoppingList() throws -> [ProductAmount] {
        var productsToBuy: [ProductAmount] = []
        do {
            let query = shoppingListTable.select(
                shoppingListTable[productId],
                shoppingListTable[amount]
            )
            
            for row in try dbConnection.prepare(query) {
                
                let productId = row[shoppingListTable[productId]]
                let productToBuyAmount = row[shoppingListTable[amount]]
                
                let product = try fetchProductById(productIdToFetch: productId!)
                let productAmount = ProductAmount(product: product, amount: productToBuyAmount!)
                
                productsToBuy.append(productAmount)
            }
            return productsToBuy
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.productToBuy)): \(error)")
        }
    }
    
  
    

    
    func fetchDishCategories() throws -> [Category] {
        var categories: [Category] = []
        
        var selectQuery = dishCategoriesTable
            .select(
                dishCategoriesTable[id],
                dishCategoriesTable[categoryName]
            ).order(dishCategoriesTable[categoryName])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let categoryId = row[dishCategoriesTable[id]]
                let categoryName = row[dishCategoriesTable[categoryName]]
                
                let category = Category(id: categoryId, name: categoryName)
                categories.append(category)
            }
            return categories
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.dishCategory)): \(error)")
        }
    }
    
    func fetchDishCategoryById(dishCategoryToFetch: Int) throws -> Category {
        var category: Category!
        
        let selectQuery = dishCategoriesTable
            .select(
                dishCategoriesTable[id],
                dishCategoriesTable[categoryName]
            ).filter(dishCategoriesTable[id] == dishCategoryToFetch)
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let categoryId = row[dishCategoriesTable[id]]
                let categoryName = row[dishCategoriesTable[categoryName]]
                
                category = Category(id: categoryId, name: categoryName)
            }
            return category
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.dishCategory)): \(error)")
        }
    }
    
    func fetchProductCategories() throws -> [Category] {
        var categories: [Category] = []
        
        let selectQuery = productCategoriesTable
            .select(
                productCategoriesTable[id],
                productCategoriesTable[categoryName]
            ).order(productCategoriesTable[categoryName])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let categoryId = row[productCategoriesTable[id]]
                let categoryName = row[productCategoriesTable[categoryName]]
                
                let category = Category(id: categoryId, name: categoryName)
                categories.append(category)
            }
            return categories
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.productCategory)): \(error)")
        }
    }
    
    func fetchProductCategoryById(productCategoryToFetch: Int) throws -> Category {
        var category: Category!
        
        let selectQuery = productCategoriesTable
            .select(
                productCategoriesTable[id],
                productCategoriesTable[categoryName]
            ).filter(productCategoriesTable[id] == productCategoryToFetch)
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let categoryId = row[productCategoriesTable[id]]
                let categoryName = row[productCategoriesTable[categoryName]]
                
                category = Category(id: categoryId, name: categoryName)
            }
            return category
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.productCategory)): \(error)")
        }
    }
    
    // ############### INSERT SECTION ############### //
    
    
    func insertRecipe(recipe: Recipe) throws {
        let insertRecipeQuery = recipeTable.insert(
            dateTime <- DateUtils.convertDateToIntValue(dateToConvert: recipe.dateTime),
            amount <- recipe.amount,
            photo <- recipe.photo
        )
        
        do {
            recipe.id = try Int(dbConnection.run(insertRecipeQuery))
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(Constants.recipe)): \(error)")
        }
    }
    
    func insertToEatHistory(eatItem: EatHistory) throws {
        let insertEatItemQuery = eatHistoryTable.insert(
            dateTime <- DateUtils.convertDateToIntValue(dateToConvert: eatItem.dateTime),
            amount <- eatItem.amount,
            productId <- eatItem.product?.id,
            dishId <- eatItem.dish?.id
        )
        
        do {
            eatItem.id = try Int(dbConnection.run(insertEatItemQuery))
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(Constants.eatHistoryItem)): \(error)")
        }
    }
    

    
    func insertDish(dish: Dish) throws {
        
        let insertDishQuery = dishTable.insert(
            name <- dish.name,
            photo <- dish.photo,
            archived <- dish.archived,
            favourite <- dish.favourite,
            categoryId <- dish.category.id!,
            description <- dish.description,
            amountOfPortion <- dish.amountOfPortion)
        do {
            dish.id = try Int(dbConnection.run(insertDishQuery))
            try insertProductAmountForDish(dish: dish)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(Constants.dish)): \(error)")
        }
    }
    
    func insertProductAmountForDish(dish: Dish) throws {
        do {
            for productAmount in dish.productAmounts {
                let insertProductAmountQuery = productAmountTable.insert(
                    self.dishId <- Int(dish.id!),
                    self.productId <- productAmount.product.id!,
                    self.amount <- productAmount.amount
                )
                try dbConnection.run(insertProductAmountQuery)
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(Constants.productAmount)): \(error)")
        }
    }
    
    func insertProductToShoppingList(productToBuy: ProductAmount) throws {
        do {
            
            if let existingProduct = try dbConnection.pluck(shoppingListTable.filter(productId == productToBuy.product.id!)) {
                let updateQuery = shoppingListTable.filter(productId == productToBuy.product.id!)
                    .update(amount <- existingProduct[amount]! + productToBuy.amount)
                try dbConnection.run(updateQuery)
            } else {
                try dbConnection.run(shoppingListTable.insert(productId <- productToBuy.product.id!,
                                                              amount <- productToBuy.amount))
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsertOrUpdate) (\(Constants.product)): \(error)")
        }
    }
    
    // ############### REMOVE SECTION ############### //
    
    func removeAllProductsToBuy() throws {
        let deleteQueryProductToBuy = shoppingListTable.delete()
        
        do {
            try dbConnection.run(deleteQueryProductToBuy)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.product)): \(error)")
        }
    }
    
    func removeProductToBuy(productToBuy: ProductAmount) throws {
        let deleteQueryProductToBuy = shoppingListTable.filter(productId == productToBuy.product.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryProductToBuy)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.product)): \(error)")
        }
    }
    
    func removeEatHistoryItem(historyItem: EatHistory) throws {
        let deleteQueryEatHistoryItem = eatHistoryTable.filter(id == historyItem.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryEatHistoryItem)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.historyItem)): \(error)")
        }
    }
    
    func removeDish(dish: Dish) throws {
        let deleteQueryDish = dishTable.filter(id == dish.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryDish)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.dish)): \(error)")
        }
    }
    
    func removeProductAmountForDish(dish: Dish) throws {
        let deleteProductAmountQuery = productAmountTable.filter(dishId == dish.id!).delete()
        
        do {
            try dbConnection.run(deleteProductAmountQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.productAmount)): \(error)")
        }
    }
    

    
    func removeRecipe(recipe: Recipe) throws {
        let deleteQuery = recipeTable.filter(id == recipe.id!).delete()
        
        do {
            try dbConnection.run(deleteQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.recipe)): \(error)")
        }
    }
    
    
    
    
    
    
    
    func updateSql(updateSql: Update, tableName: String) throws {
        do {
            try dbConnection.run(updateSql)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorUpdate) (\(tableName)): \(error)")
        }
    }
    
    func fetchSql(selectSql: Table, tableName: String) throws -> [Row] {
        var results: [Row] = []
        
        do {
            for row in try dbConnection.prepare(selectSql) {
                results.append(row)
            }
            
            return results
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(tableName)): \(error)")
        }
    }
    
    func insertSql(insertSql: Insert, tableName: String) throws -> Int {
        do {
            return try Int(dbConnection.run(insertSql))
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(tableName)): \(error)")
        }
    }
    
    func deleteSql(deleteSql: Delete, tableName: String) throws {
        do {
            try dbConnection.run(deleteSql)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(tableName)): \(error)")
        }
    }
}

