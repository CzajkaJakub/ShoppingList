import Foundation
import SQLite
import SQLite3
import UIKit

class DatabaseManager {
    
    static let shared = DatabaseManager()
    private var dbConnection: Connection
    
    // Tables
    private var dishTable = Table(Constants.dishTable)
    private var recipeTable = Table(Constants.recipeTable)
    private var productsTable = Table(Constants.productsTable)
    private var eatHistoryTable = Table(Constants.eatHistoryTable)
    private var shoppingListTable = Table(Constants.productsToBuyTable)
    private var productAmountTable = Table(Constants.productAmountTable)
    private var dishCategoriesTable = Table(Constants.dishCategoriesTable)
    private var productCategoriesTable = Table(Constants.productCategoriesTable)

    // Foreign keys columns
    private var dishId = Expression<Int?>(Constants.dishId)
    private var productId = Expression<Int?>(Constants.productId)
    private var categoryId = Expression<Int>(Constants.categoryId)

    // Columns
    private var id = Expression<Int>(Constants.idColumn)
    private var fat = Expression<Double>(Constants.fatColumn)
    private var name = Expression<String>(Constants.nameColumn)
    private var photo = Expression<Blob>(Constants.photoColumn)
    private var carbo = Expression<Double>(Constants.carboColumn)
    private var amount = Expression<Double?>(Constants.amountColumn)
    private var dateTime = Expression<Int>(Constants.dateTimeColumn)
    private var protein = Expression<Double>(Constants.proteinColumn)
    private var archived = Expression<Bool>(Constants.archivedColumn)
    private var calories = Expression<Double>(Constants.caloriesColumn)
    private var favourite = Expression<Bool>(Constants.favouriteColumn)
    private var description = Expression<String?>(Constants.descriptionColumn)
    private var categoryName = Expression<String>(Constants.categoryNameColumn)
    private var weightOfPiece = Expression<Double?>(Constants.weightOfPieceColumn)
    private var weightOfProduct = Expression<Double?>(Constants.weightOfProductColumn)
    private var amountOfPortion = Expression<Double?>(Constants.amountOfPortionColumn)
    
    private init() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(Constants.databaseName)
        
        print(fileURL)
        
        do {
            dbConnection = try Connection(fileURL.path, readonly: false)
            sqlite3_exec(dbConnection.handle, "PRAGMA foreign_keys = on", nil, nil, nil)
            try createProductCategoriesTable()
            try createDishCategoriesTable()
            try createProductTable()
            try createDishTable()
            try createProductsToBuyTable()
            try createProductAmountTable()
            try createEatHistoryTable()
            try createRecipeTable()
            
            try insertDataIntoProductCategoriesTable()
            try insertDataIntoDishCategoriesTable()
        } catch {
            fatalError("\(Constants.errorCreateDatabase): \(error)")
        }
    }
    
    // ############### INSERT DATA INTO TABLES SECTION ############### //
    
    func insertDataIntoProductCategoriesTable() throws {

        let selectCategoriesIfNotExists = productCategoriesTable.count
        do {
            let categoryCount = try dbConnection.scalar(selectCategoriesIfNotExists)

            if categoryCount == 0 {
                let categoriesSql = Constants.productCategories.map { categoryName in
                    return productCategoriesTable.insert(self.categoryName <- categoryName)
                }

                for query in categoriesSql {
                    do {
                        try dbConnection.run(query)
                    } catch {
                        throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productCategoriesTable)): \(error)")
                    }
                }
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productCategoriesTable)): \(error)")
        }
    }
    
    func insertDataIntoDishCategoriesTable() throws {
        
        let selectCategoriesIfNotExists = dishCategoriesTable.count
        do {
            let categoryCount = try dbConnection.scalar(selectCategoriesIfNotExists)
            
            if categoryCount == 0 {
                let categoriesSql = Constants.dishCategories.map { categoryName in
                    return dishCategoriesTable.insert(self.categoryName <- categoryName)
                }
                
                for query in categoriesSql {
                    do {
                        try dbConnection.run(query)
                    } catch {
                        throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishCategoriesTable)): \(error)")
                    }
                }
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishCategoriesTable)): \(error)")
        }
    }
    
    // ############### CREATE TABLES SECTION ############### //
    
    func createProductCategoriesTable() throws {
        let createCategoriesTableQuery = productCategoriesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(categoryName)
        }
        
        do {
            try dbConnection.run(createCategoriesTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productCategoriesTable)): \(error)")
        }
    }
    
    func createDishCategoriesTable() throws {
        let createCategoriesTableQuery = dishCategoriesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(categoryName, unique: true)
        }
        
        do {
            try dbConnection.run(createCategoriesTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishCategoriesTable)): \(error)")
        }
    }
    
    func createProductTable() throws {
        let createProductsTableQuery = productsTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(fat)
            table.column(name)
            table.column(carbo)
            table.column(photo)
            table.column(protein)
            table.column(archived)
            table.column(calories)
            table.column(categoryId)
            table.column(weightOfPiece)
            table.column(weightOfProduct)
            table.foreignKey(categoryId, references: productCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductsTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productsTable)): \(error)")
        }
    }
    
    
    func createDishTable() throws {
        let createDishTableQuery = dishTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(name)
            table.column(photo)
            table.column(archived)
            table.column(favourite)
            table.column(categoryId)
            table.column(description)
            table.column(amountOfPortion)
            table.foreignKey(categoryId, references: dishCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createDishTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.dishTable)): \(error)")
        }
    }
    
    func createProductAmountTable() throws {
        let createProductAmountTableQuery = productAmountTable.create(ifNotExists: true) { table in
            table.column(dishId)
            table.column(productId)
            table.column(amount)
            table.foreignKey(dishId, references: dishTable, id, update: .cascade, delete: .cascade)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductAmountTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productAmountTable)): \(error)")
        }
    }
    
    func createProductsToBuyTable() throws {
        let createProductsToBuyTableQuery = shoppingListTable.create(ifNotExists: true) { table in
            table.column(productId)
            table.column(amount)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductsToBuyTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.productsToBuyTable)): \(error)")
        }
    }
    
    func createEatHistoryTable() throws {
        let createEatHistoryTableQuery = eatHistoryTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(dateTime)
            table.column(amount, defaultValue: nil)
            table.column(productId, defaultValue: nil)
            table.column(dishId, defaultValue: nil)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
            table.foreignKey(dishId, references: dishTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createEatHistoryTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.eatHistoryTable)): \(error)")
        }
    }
    
    func createRecipeTable() throws {
        let createRecipeTableQuery = recipeTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(dateTime)
            table.column(amount)
            table.column(photo)
        }
        
        do {
            try dbConnection.run(createRecipeTableQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorCreateDatabase) (\(Constants.recipeTable)): \(error)")
        }
    }

    // ############### UPDATE SECTION ############### //
    
    func archiveProduct(product: Product) throws {
        
        do {
            let archiveProductQuery = productsTable.filter(id == product.id!)
                .update(archived <- true)
            
            try dbConnection.run(archiveProductQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorArchive) (\(Constants.product)): \(error)")
        }
    }
    
    func updateProduct(product: Product) throws {
        
        do {
            if let _ = try dbConnection.pluck(productsTable.filter(id == product.id!)) {
                
                let updateProductQuery = productsTable.filter(id == product.id!)
                    .update(name <- product.name,
                            fat <- product.fat,
                            photo <- product.photo,
                            carbo <- product.carbo,
                            protein <- product.protein,
                            archived <- product.archived,
                            calories <- product.calories,
                            categoryId <- product.category.id!,
                            weightOfPiece <- product.weightOfPiece,
                            weightOfProduct <- product.weightOfProduct)
                
                try dbConnection.run(updateProductQuery)
            }
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorUpdate) (\(Constants.product)): \(error)")
        }
    }
    
    func archiveDish(dish: Dish) throws {
        
        do {
            let archiveDishQuery = dishTable.filter(id == dish.id!)
                .update(archived <- true)
            
            try dbConnection.run(archiveDishQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorArchive) (\(Constants.dish)): \(error)")
        }
    }
    
    func updateDish(dish: Dish) throws {
        do {
            if let _ = try dbConnection.pluck(dishTable.filter(id == dish.id!)) {
                
                let updateDishQuery = dishTable.filter(id == dish.id!)
                    .update(name <- dish.name,
                            photo <- dish.photo,
                            archived <- dish.archived,
                            favourite <- dish.favourite,
                            categoryId <- dish.category.id!,
                            description <- dish.description,
                            amountOfPortion <- dish.amountOfPortion)
                
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
    
    func fetchEatHistory(dateFrom: Date, dateTo: Date) throws -> [EatHistoryItem] {
        var eatHistory: [EatHistoryItem] = []
        
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
                
                let eatHistoryItem: EatHistoryItem!
                
                if productId != nil {
                    let product = try fetchProductById(productIdToFetch: productId!)
                    eatHistoryItem = EatHistoryItem(id: eatHistoryId, dateValue: dateTime, dish: nil, product: product, amount: amount!)
                } else if dishId != nil {
                    let dish = try fetchDishById(dishIdToFetch: dishId!)
                    eatHistoryItem = EatHistoryItem(id: eatHistoryId, dateValue: dateTime, dish: dish, product: nil, amount: amount!)
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
    
    func fetchProducts() throws -> [Product] {
        var products: [Product] = []
        
        let selectQuery = productsTable
            .select(
                productsTable[*])
            .filter(productsTable[archived] == false)
            .order(productsTable[name])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let fat = row[productsTable[fat]]
                let name = row[productsTable[name]]
                let carbo = row[productsTable[carbo]]
                let productId = row[productsTable[id]]
                let kcal = row[productsTable[calories]]
                let protein = row[productsTable[protein]]
                let photoBlob = row[productsTable[photo]]
                let archived = row[productsTable[archived]]
                let categoryId = row[productsTable[categoryId]]
                let weightOfPiece = row[productsTable[weightOfPiece]]
                let weightOfProduct = row[productsTable[weightOfProduct]]

                let category = try fetchProductCategoryById(productCategoryToFetch: categoryId)
                let product = Product(id: productId, name: name, photo: photoBlob, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, weightOfProduct: weightOfProduct, archived: archived, category: category)
                products.append(product)
            }
            return products
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.product)): \(error)")
        }
    }
    
    func fetchProductById(productIdToFetch: Int) throws -> Product {
        var product: Product!
        
        let selectQuery = productsTable
            .select(
                productsTable[*]
            ).filter(productsTable[id] == productIdToFetch)
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let fat = row[productsTable[fat]]
                let name = row[productsTable[name]]
                let carbo = row[productsTable[carbo]]
                let productId = row[productsTable[id]]
                let kcal = row[productsTable[calories]]
                let protein = row[productsTable[protein]]
                let photoBlob = row[productsTable[photo]]
                let archived = row[productsTable[archived]]
                let categoryId = row[productsTable[categoryId]]
                let weightOfPiece = row[productsTable[weightOfPiece]]
                let weightOfProduct = row[productsTable[weightOfProduct]]

                let category = try fetchProductCategoryById(productCategoryToFetch: categoryId)
                product = Product(id: productId, name: name, photo: photoBlob, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, weightOfProduct: weightOfProduct, archived: archived, category: category)
            }
            return product
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorFetch) (\(Constants.product)): \(error)")
        }
    }
    
    func fetchDishCategories() throws -> [Category] {
        var categories: [Category] = []
        
        let selectQuery = dishCategoriesTable
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
    
    func insertToEatHistory(eatItem: EatHistoryItem) throws {
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
    
    func insertProduct(product: Product) throws {
        let insertQuery = productsTable.insert(
            fat <- product.fat,
            name <- product.name,
            photo <- product.photo,
            carbo <- product.carbo,
            protein <- product.protein,
            archived <- product.archived,
            calories <- product.calories,
            categoryId <- product.category.id!,
            weightOfPiece <- product.weightOfPiece,
            weightOfProduct <- product.weightOfProduct
        )
        
        do {
            product.id = try Int(dbConnection.run(insertQuery))
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorInsert) (\(Constants.product)): \(error)")
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
    
    func removeProductToBuy(productToBuy: ProductAmount) throws {
        let deleteQueryProductToBuy = shoppingListTable.filter(productId == productToBuy.product.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryProductToBuy)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.product)): \(error)")
        }
    }
    
    func removeEatHistoryItem(historyItem: EatHistoryItem) throws {
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
    
    func removeProduct(product: Product) throws {
        let deleteQuery = productsTable.filter(id == product.id!).delete()
        
        do {
            try dbConnection.run(deleteQuery)
        } catch {
            throw DatabaseError.runtimeError("\(Constants.errorRemove) (\(Constants.product)): \(error)")
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
}
    
