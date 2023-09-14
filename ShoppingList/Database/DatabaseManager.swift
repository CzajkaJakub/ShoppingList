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
    private var productsToBuyTable = Table(Constants.productsToBuyTable)
    private var productAmountTable = Table(Constants.productAmountTable)
    private var dishCategoriesTable = Table(Constants.dishCategoriesTable)
    private var productCategoriesTable = Table(Constants.productCategoriesTable)

    
    // Foreign keys columns
    private var dishId = Expression<Int?>(Constants.dishId)
    private var productId = Expression<Int?>(Constants.productId)
    private var categoryId = Expression<Int>(Constants.categoryId)

    // Columns
    private var id = Expression<Int>(Constants.id)
    private var fat = Expression<Double>(Constants.fat)
    private var name = Expression<String>(Constants.name)
    private var photo = Expression<Blob>(Constants.photo)
    private var carbo = Expression<Double>(Constants.carbo)
    private var amount = Expression<Double?>(Constants.amount)
    private var dateTime = Expression<Int>(Constants.dateTime)
    private var protein = Expression<Double>(Constants.protein)
    private var calories = Expression<Double>(Constants.calories)
    private var favourite = Expression<Bool>(Constants.favourite)
    private var description = Expression<String?>(Constants.description)
    private var categoryName = Expression<String>(Constants.categoryName)
    private var weightOfPiece = Expression<Double?>(Constants.weightOfPiece)
    
    private init() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("fitForYou.sqlite")
        
        print(fileURL)
        
        do {
            dbConnection = try Connection(fileURL.path, readonly: false)
            sqlite3_exec(dbConnection.handle, "PRAGMA foreign_keys = on", nil, nil, nil)
            createProductCategoriesTableAndInsertData()
            createDishCategoriesTableAndInsertData()
            createProductTable()
            createDishTable()
            createProductsToBuyTable()
            createProductAmountTable()
            createEatHistoryTable()
            createRecipeTable()
        } catch {
            Alert.displayErrorAlert(message: "Error opening database: \(error)")
            fatalError("Failed to open database")
        }
    }
    
    func reloadProductsDishesFromDatabase() {
        Product.products = DatabaseManager.shared.fetchProducts()
        Dish.dishes = DatabaseManager.shared.fetchDishes()
        ProductAmount.productsToBuy = DatabaseManager.shared.fetchProductsToBuy()
    }
    
    func createProductCategoriesTableAndInsertData() {
        let createCategoriesTableQuery = productCategoriesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(categoryName, unique: true)
        }
        
        do {
            try dbConnection.run(createCategoriesTableQuery)
        } catch {
            Alert.displayErrorAlert(message: "Error creating categories table: \(error)")
        }
        
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
                        Alert.displayErrorAlert(message: "Error creating categories records: \(error)")
                    }
                }
            }
        } catch {
            Alert.displayErrorAlert(message: "Error counting categories records: \(error)")
        }
    }
    
    func createDishCategoriesTableAndInsertData() {
        let createCategoriesTableQuery = dishCategoriesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(categoryName, unique: true)
        }
        
        do {
            try dbConnection.run(createCategoriesTableQuery)
        } catch {
            Alert.displayErrorAlert(message: "Error creating dish categories table: \(error)")
        }
        
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
                        Alert.displayErrorAlert(message: "Error creating dish categories records: \(error)")
                    }
                }
            }
        } catch {
            Alert.displayErrorAlert(message: "Error counting cdish ategories records: \(error)")
        }
    }
    
    func createProductTable(){
        let createProductsTableQuery = productsTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(name)
            table.column(photo)
            table.column(calories)
            table.column(protein)
            table.column(fat)
            table.column(carbo)
            table.column(categoryId)
            table.column(weightOfPiece)
            table.foreignKey(categoryId, references: productCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductsTableQuery)
        } catch {
            Alert.displayErrorAlert(message: "Error creating products table: \(error)")
        }
    }
    
    
    func createDishTable() {
        let createDishTableQuery = dishTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(name, unique: true)
            table.column(favourite)
            table.column(description)
            table.column(photo)
            table.column(categoryId)
            table.foreignKey(categoryId, references: dishCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createDishTableQuery)
        } catch {
            Alert.displayErrorAlert(message: "Error creating dish table: \(error)")
        }
    }
    
    func createProductAmountTable(){
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
            Alert.displayErrorAlert(message: "Error creating product_amount table: \(error)")
        }
    }
    
    func createProductsToBuyTable(){
        let createProductsToBuyTableQuery = productsToBuyTable.create(ifNotExists: true) { table in
            table.column(productId)
            table.column(amount)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductsToBuyTableQuery)
        } catch {
            Alert.displayErrorAlert(message: "Error creating products_to_buy table: \(error)")
        }
    }
    
    func createEatHistoryTable(){
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
            Alert.displayErrorAlert(message: "Error creating eat history table: \(error)")
        }
    }
    
    func createRecipeTable(){
        let createRecipeTableQuery = recipeTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(dateTime)
            table.column(amount)
            table.column(photo)
        }
        
        do {
            try dbConnection.run(createRecipeTableQuery)
        } catch {
            Alert.displayErrorAlert(message: "Error creating recipe table: \(error)")
        }
    }
    
    func fetchRecipes(dateFrom: Date, dateTo: Date) -> [Recipe] {
        var recipes: [Recipe] = []
        
        let selectQuery = recipeTable
            .select(recipeTable[*])
            .filter(recipeTable[dateTime] >= DateUtils.convertDateToIntValue(dateToConvert: dateFrom) &&
                    recipeTable[dateTime] <= DateUtils.convertDateToIntValue(dateToConvert: dateTo)).order(recipeTable[dateTime])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let recipeId = row[recipeTable[id]]
                let dateTime = row[recipeTable[dateTime]]
                let amount = row[recipeTable[amount]]
                let photo = row[recipeTable[photo]]
                
                let recipe = Recipe(id: recipeId, dateValue: dateTime, amount: amount!, photo: photo)
                recipes.append(recipe)
            }
        } catch {
            Alert.displayErrorAlert(message: "Error selecting records: \(error)")
        }
        
        return recipes
    }
    
    func insertRecipe(recipe: Recipe) -> Bool {
        let insertRecipeQuery = recipeTable.insert(
            dateTime <- DateUtils.convertDateToIntValue(dateToConvert: recipe.dateTime),
            amount <- recipe.amount,
            photo <- recipe.photo
        )
        
        do {
            let recipeId = try dbConnection.run(insertRecipeQuery)
            recipe.id = Int(recipeId)
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error inserting record: \(error)")
            return false
        }
    }
    
    func removeRecipe(recipe: Recipe) -> Bool {
        let deleteQuery = recipeTable.filter(id == recipe.id!).delete()
        
        do {
            try dbConnection.run(deleteQuery)
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error removing recipe: \(error)")
            return false
        }
    }
    
    func insertToEatHistory(eatItem: EatHistoryItem) -> Bool {
        let insertEatItemQuery = eatHistoryTable.insert(
            dateTime <- DateUtils.convertDateToIntValue(dateToConvert: eatItem.dateTime),
            amount <- eatItem.productAmount?.amount,
            productId <- eatItem.productAmount?.product.id,
            dishId <- eatItem.dish?.id
        )
        
        do {
            let eatHistoryId = try dbConnection.run(insertEatItemQuery)
            eatItem.id = Int(eatHistoryId)
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error inserting record: \(error)")
            return false
        }
    }
    
    func fetchEatHistory(dateFrom: Date, dateTo: Date) -> [EatHistoryItem] {
        var eatHistory: [EatHistoryItem] = []
        
        let selectQuery = eatHistoryTable
            .select(
                eatHistoryTable[id],
                eatHistoryTable[amount],
                eatHistoryTable[dateTime],
                eatHistoryTable[dishId],
                eatHistoryTable[productId])
            .filter(eatHistoryTable[dateTime] >= DateUtils.convertDateToIntValue(dateToConvert: dateFrom) &&
                    eatHistoryTable[dateTime] <= DateUtils.convertDateToIntValue(dateToConvert: dateTo))
            .order(eatHistoryTable[dateTime])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let eatHistoryId = row[eatHistoryTable[id]]
                let dateTime = row[eatHistoryTable[dateTime]]
                let productId = row[eatHistoryTable[productId]]
                let dishIdToFetch = row[eatHistoryTable[dishId]]
                let amount = row[eatHistoryTable[amount]]
                
                if productId != nil {
                    let product = fetchProductcById(productIdToFetch: productId!)
                    let productAmount = ProductAmount(product: product, amount: amount!)
                    let eatHistoryItem = EatHistoryItem(id: eatHistoryId, dateValue: dateTime, productAmount: productAmount)
                    eatHistory.append(eatHistoryItem)
                } else {
                    let dish = fetchDishById(dishIdToFetch: dishIdToFetch!)
                    let eatHistoryItem = EatHistoryItem(id: eatHistoryId, dateValue: dateTime, dish: dish)
                    eatHistory.append(eatHistoryItem)
                }
            }
        } catch {
            Alert.displayErrorAlert(message: "Error selecting records: \(error)")
        }
        
        return eatHistory
    }

    func insertProduct(product: Product) -> Bool {
        let insertQuery = productsTable.insert(
            name <- product.name,
            photo <- product.photo,
            calories <- product.calories,
            protein <- product.protein,
            fat <- product.fat,
            carbo <- product.carbo,
            weightOfPiece <- product.weightOfPiece,
            categoryId <- product.category.id!
        )
        
        do {
            let productId = try dbConnection.run(insertQuery)
            product.id = Int(productId)
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error inserting record: \(error)")
            return false
        }
    }
    
    func updateProduct(product: Product) -> Bool {
        do {
            if let _ = try dbConnection.pluck(productsTable.filter(id == product.id!)) {
                
                let updateProductQuery = productsTable.filter(id == product.id!)
                    .update(name <- product.name,
                            calories <- product.calories,
                            protein <- product.protein,
                            fat <- product.fat,
                            carbo <- product.carbo,
                            photo <- product.photo,
                            weightOfPiece <- product.weightOfPiece,
                            categoryId <- product.category.id!)
                do {
                    try dbConnection.run(updateProductQuery)
                    return true
                } catch {
                    Alert.displayErrorAlert(message: "Error updating product: \(error)")
                    return false
                }
            }
        } catch {
            Alert.displayErrorAlert(message: "Product not found id: \(product.id!)")
            return false
        }
        return true
    }
    
    
    func removeProduct(product: Product) -> Bool {
        let deleteQuery = productsTable.filter(id == product.id!).delete()
        
        do {
            try dbConnection.run(deleteQuery)
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error removing product: \(error)")
            return false
        }
    }
    
    func fetchProducts() -> [Product] {
        var products: [Product] = []
        
        let selectQuery = productsTable
            .join(productCategoriesTable, on: productsTable[categoryId] == productCategoriesTable[id])
            .select(
                productsTable[id],
                productsTable[name],
                productsTable[photo],
                productsTable[calories],
                productsTable[protein],
                productsTable[weightOfPiece],
                productsTable[fat],
                productsTable[carbo],
                productCategoriesTable[id], // Use the alias directly instead of categoryId
                productCategoriesTable[categoryName]
            ).order(productsTable[name])
        
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let dbId = row[productsTable[id]]
                let name = row[productsTable[name]]
                let photoBlob = row[productsTable[photo]]
                let kcal = row[productsTable[calories]]
                let protein = row[productsTable[protein]]
                let fat = row[productsTable[fat]]
                let weightOfPiece = row[productsTable[weightOfPiece]]
                let carbo = row[productsTable[carbo]]
                let categoryId = row[productCategoriesTable[id]] // Use the alias directly instead of categoryId
                let categoryName = row[productCategoriesTable[categoryName]]
                
                let category = Category(id: categoryId, name: categoryName)
                let product = Product(id: dbId, name: name, photo: photoBlob, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, category: category)
                products.append(product)
            }
        } catch {
            Alert.displayErrorAlert(message: "Error selecting records: \(error)")
        }
        
        return products
    }
    
    
    func fetchProductcById(productIdToFetch: Int) -> Product {
        var product: Product!
        
        let selectQuery = productsTable
            .join(productCategoriesTable, on: productsTable[categoryId] == productCategoriesTable[id])
            .select(
                productsTable[id],
                productsTable[name],
                productsTable[photo],
                productsTable[calories],
                productsTable[protein],
                productsTable[weightOfPiece],
                productsTable[fat],
                productsTable[carbo],
                productCategoriesTable[id],
                productCategoriesTable[categoryName]
            ).filter(productsTable[id] == productIdToFetch)
        
        for row in try! dbConnection.prepare(selectQuery) {
            let dbId = row[productsTable[id]]
            let name = row[productsTable[name]]
            let photo = row[productsTable[photo]]
            let kcal = row[productsTable[calories]]
            let protein = row[productsTable[protein]]
            let weightOfPiece = row[productsTable[weightOfPiece]]
            let fat = row[productsTable[fat]]
            let carbo = row[productsTable[carbo]]
            let categoryId = row[productCategoriesTable[id]] // Use the alias directly instead of categoryId
            let categoryName = row[productCategoriesTable[categoryName]]
            
            let category = Category(id: categoryId, name: categoryName)
            product = Product(id: dbId, name: name, photo: photo, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, category: category)
        }
        return product
    }
    
    func fetchProductCategories() -> [Category] {
        var categories: [Category] = []
        
        let selectQuery = productCategoriesTable
            .select(
                productCategoriesTable[id], // Use the alias directly instead of categoryId
                productCategoriesTable[categoryName]
            ).order(productCategoriesTable[categoryName])
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let categoryId = row[productCategoriesTable[id]] // Use the alias directly instead of categoryId
                let categoryName = row[productCategoriesTable[categoryName]]
                
                let category = Category(id: categoryId, name: categoryName)
                categories.append(category)
            }
        } catch {
            Alert.displayErrorAlert(message: "Error selecting records: \(error)")
        }
        
        return categories
    }
    
    
    func fetchDishCategories() -> [Category] {
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
        } catch {
            Alert.displayErrorAlert(message: "Error selecting records: \(error)")
        }
        
        return categories
    }
    
    func fetchDishes() -> [Dish] {
        var dishes: [Dish] = []
        do {
            let dishFetchQuery = dishTable.join(dishCategoriesTable, on: dishTable[categoryId] == dishCategoriesTable[id]).order(dishTable[name])
            
            for dishRow in try dbConnection.prepare(dishFetchQuery) {
                let dishId = dishRow[dishTable[id]]
                let dishName = dishRow[dishTable[name]]
                let dishPhoto = dishRow[dishTable[photo]]
                let dishFavourite = dishRow[dishTable[favourite]]
                let dishDescription = dishRow[dishTable[description]]
                let dishCategoryId = dishRow[dishCategoriesTable[id]]
                let dishCategoryName = dishRow[dishCategoriesTable[categoryName]]
                let dishCategory = Category(id: dishCategoryId, name: dishCategoryName)
                let productAmountsForDish = fetchProductsAmountForDish(dishIdToSearch: dishId)
                
                dishes.append(Dish(id: dishId, name: dishName, description: dishDescription, favourite: dishFavourite, photo: dishPhoto, productAmounts: productAmountsForDish, category: dishCategory))
                
            }
        } catch {
            Alert.displayErrorAlert(message: "Error fetching dish: \(error)")
        }
        return dishes
    }
    
    func fetchDishById(dishIdToFetch: Int) -> Dish {
        var dish: Dish!
        let dishFetchQuery = dishTable.join(dishCategoriesTable, on: dishTable[categoryId] == dishCategoriesTable[id]).filter(dishTable[id] == dishIdToFetch)

        for dishRow in try! dbConnection.prepare(dishFetchQuery) {
            let dishId = dishRow[dishTable[id]]
            let dishName = dishRow[dishTable[name]]
            let dishPhoto = dishRow[dishTable[photo]]
            let dishFavourite = dishRow[dishTable[favourite]]
            let dishDescription = dishRow[dishTable[description]]
            let dishCategoryId = dishRow[dishCategoriesTable[id]]
            let dishCategoryName = dishRow[dishCategoriesTable[categoryName]]
            let dishCategory = Category(id: dishCategoryId, name: dishCategoryName)
            let productAmountsForDish = fetchProductsAmountForDish(dishIdToSearch: dishId)

            dish = Dish(id: dishId, name: dishName, description: dishDescription, favourite: dishFavourite, photo: dishPhoto, productAmounts: productAmountsForDish, category: dishCategory)
        }
        return dish
    }
    
    func fetchProductsAmountForDish(dishIdToSearch: Int) -> [ProductAmount] {
        var productAmountsForDish: [ProductAmount] = []
        
        let productsForDishQuery = productAmountTable.join(productsTable, on: productAmountTable[productId] == productsTable[id])
            .join(productCategoriesTable, on: productsTable[categoryId] == productCategoriesTable[id])
            .select(productsTable[*], productAmountTable[*], productCategoriesTable[*])
            .filter(productAmountTable[dishId] == dishIdToSearch)
            .order(productsTable[name])
        
        do {
            for productRow in try dbConnection.prepare(productsForDishQuery) {
                let productId = productRow[productsTable[id]]
                let productName = productRow[productsTable[name]]
                let productPhoto = productRow[productsTable[photo]]
                let productKcal = productRow[productsTable[calories]]
                let productProtein = productRow[productsTable[protein]]
                let weightOfPiece = productRow[productsTable[weightOfPiece]]
                let productFat = productRow[productsTable[fat]]
                let productCarbo = productRow[productsTable[carbo]]
                let productCategoryId = productRow[productCategoriesTable[id]]
                let productCategoryName = productRow[productCategoriesTable[categoryName]]
                
                let dishAmount = productRow[productAmountTable[amount]]
                
                let productCategory = Category(id: productCategoryId, name: productCategoryName)
                let product = Product(id: productId, name: productName, photo: productPhoto, kcal: productKcal, carbo: productCarbo, fat: productFat, protein: productProtein, weightOfPiece: weightOfPiece, category: productCategory)
                
                let productAmount = ProductAmount(product: product, amount: dishAmount!)
                productAmountsForDish.append(productAmount)
            }
        } catch {
            Alert.displayErrorAlert(message: "Error fetching dish (\(dishId): \(error)")
        }
        
        return productAmountsForDish
    }
    
    func insertProductAmountForDish(dish: Dish) -> Bool {
        do {
            for productAmount in dish.productAmounts {
                let insertProductAmountQuery = productAmountTable.insert(
                    self.dishId <- Int(dish.id!),
                    self.productId <- productAmount.product.id!,
                    self.amount <- productAmount.amount
                )
                try dbConnection.run(insertProductAmountQuery)
                return true
            }
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error inserting product amount: \(error)")
            return false
        }
    }
    
    func removeProductAmountForDish(dish: Dish) -> Bool {
        let deleteProductAmountQuery = productAmountTable.filter(dishId == dish.id!).delete()
        
        do {
            try dbConnection.run(deleteProductAmountQuery)
            return true
        } catch {
            Alert.displayErrorAlert(message: "\(Constants.errorRemoveProductAmount) : \(error)")
            return false
        }
    }
    
    func insertDish(dish: Dish) -> Bool {
        
        let insertDishQuery = dishTable.insert(
            name <- dish.name,
            photo <- dish.photo,
            favourite <- dish.favourite,
            description <- dish.description,
            categoryId <- dish.category.id!)
        do {
            dish.id = try Int(dbConnection.run(insertDishQuery))
            if (insertProductAmountForDish(dish: dish)){
                return true
            }
            return false
        } catch {
            Alert.displayErrorAlert(message: "\(Constants.errorInsertDish) : \(error)")
            return false
        }
    }
    
    func updateDish(dish: Dish) -> Bool {
        do {
            if let _ = try dbConnection.pluck(dishTable.filter(id == dish.id!)) {
                
                let updateDishQuery = dishTable.filter(id == dish.id!)
                    .update(name <- dish.name,
                            photo <- dish.photo,
                            favourite <- dish.favourite,
                            description <- dish.description,
                            categoryId <- dish.category.id!)
                do {
                    try dbConnection.run(updateDishQuery)
                    if (!removeProductAmountForDish(dish: dish)) {
                        return false
                    }
                    if (!insertProductAmountForDish(dish: dish)) {
                        return false
                    }
                } catch {
                    Alert.displayErrorAlert(message: "Error updating dish: \(error)")
                    return false
                }
            }
        } catch {
            Alert.displayErrorAlert(message: "Dish not found id: \(dish.id!)")
            return false
        }
        return true
    }
    
    func removeDish(dish: Dish) -> Bool {
        let deleteQueryDish = dishTable.filter(id == dish.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryDish)
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error removing product: \(error)")
            return false
        }
    }
    
    func addDishToShoppingList(dish: Dish) -> Bool {
        for productAmount in dish.productAmounts {
            if addProductToShoppingList(productToBuy: productAmount) {
                return false
            }
        }
        return true
    }

    
    func addProductToShoppingList(productToBuy: ProductAmount) -> Bool {
        do {
            if let existingProduct = try dbConnection.pluck(productsToBuyTable.filter(productId == productToBuy.product.id!)) {
                // Product exists, perform an update
                let updateQuery = productsToBuyTable.filter(productId == productToBuy.product.id!)
                    .update(amount <- existingProduct[amount]! + productToBuy.amount)
                try dbConnection.run(updateQuery)
            } else {
                try dbConnection.run(productsToBuyTable.insert(productId <- productToBuy.product.id!,
                                                               amount <- productToBuy.amount))
                return true
            }
            return true
        } catch {
            Alert.displayErrorAlert(message: "Error adding/updating product: \(error)")
            return false
        }
    }
    
    func fetchProductsToBuy() -> [ProductAmount] {
        var productsToBuy: [ProductAmount] = []
        do {
            let query = productsToBuyTable.join(productsTable, on: productsToBuyTable[productId] == productsTable[id])
                .join(productCategoriesTable, on: productsTable[categoryId] == productCategoriesTable[id])
                .select( productsTable[*], productsToBuyTable[*], productCategoriesTable[*])
                .order(productsTable[name])
            
            for row in try dbConnection.prepare(query) {
                
                let productId = row[productsTable[id]]
                let productName = row[productsTable[name]]
                let productPhoto = row[productsTable[photo]]
                let productKcal = row[productsTable[calories]]
                let productProtein = row[productsTable[protein]]
                let weightOfPiece = row[productsTable[weightOfPiece]]
                let productFat = row[productsTable[fat]]
                let productCarbo = row[productsTable[carbo]]
                let productCategoryId = row[productCategoriesTable[id]]
                let productCategoryName = row[productCategoriesTable[categoryName]]
                
                let productToBuyAmount = row[productsToBuyTable[amount]]
                
                let product = Product(id: productId, name: productName, photo: productPhoto, kcal: productKcal, carbo: productCarbo, fat: productFat, protein: productProtein, weightOfPiece: weightOfPiece, category: Category(id: productCategoryId, name: productCategoryName))
                
                let productAmount = ProductAmount(product: product, amount: productToBuyAmount!)
                productsToBuy.append(productAmount)
            }
            
        } catch {
            Alert.displayErrorAlert(message: "Error fetching products to buy: \(error)")
        }
        return productsToBuy
    }
    
    func removeProductToBuy(productToBuy: ProductAmount) -> Bool {
        let deleteQueryProductToBuy = productsToBuyTable.filter(productId == productToBuy.product.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryProductToBuy)
            return true
            
        } catch {
            Alert.displayErrorAlert(message: "Error removing product: \(error)")
            return false
        }
    }
    
    func removeEatHistoryItem(historyItem: EatHistoryItem) -> Bool {
        let deleteQueryEatHistoryItem = eatHistoryTable.filter(id == historyItem.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryEatHistoryItem)
            return true
            
        } catch {
            Alert.displayErrorAlert(message: "Error removing history item: \(error)")
            return false
        }
    }
}
    
