//
//  DatabaseManager.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class DatabaseManager {
    static let shared = DatabaseManager()
    private var dbConnection: Connection
    
    //Tables
    private var productsTable = Table("products")
    private var productCategoriesTable = Table("product_category")
    private var dishCategoriesTable = Table("dish_category")
    private var productsToBuyTable = Table("products_to_buy")
    private var productAmountTable = Table("product_amount")
    private var dishTable = Table("dish")
    
    //Foreign keys columns
    private var categoryId = Expression<Int>("category_id")
    private var productId = Expression<Int>("product_id")
    private var dishId = Expression<Int>("dish_id")
    
    //Columns
    private var id = Expression<Int>("id")
    private var name = Expression<String>("name")
    private var photo = Expression<Blob>("photo")
    private var calories = Expression<Double>("calories")
    private var protein = Expression<Double>("protein")
    private var fat = Expression<Double>("fat")
    private var carbo = Expression<Double>("carbo")
    private var categoryName = Expression<String>("category_name")
    private var amount = Expression<Double>("amount")

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
        } catch {
            print("Error opening database: \(error)")
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
            print("Error creating categories table: \(error)")
        }
        
        let selectCategoriesIfNotExists = productCategoriesTable.count
        do {
            let categoryCount = try dbConnection.scalar(selectCategoriesIfNotExists)
            
            if categoryCount == 0 {
                let categoriesSql = [
                    productCategoriesTable.insert(categoryName <- "Vegetables"),
                    productCategoriesTable.insert(categoryName <- "Fruits"),
                    productCategoriesTable.insert(categoryName <- "Meat"),
                    productCategoriesTable.insert(categoryName <- "Seafood"),
                    productCategoriesTable.insert(categoryName <- "Grain"),
                    productCategoriesTable.insert(categoryName <- "Fat"),
                    productCategoriesTable.insert(categoryName <- "Sweets"),
                    productCategoriesTable.insert(categoryName <- "Legumes"),
                    productCategoriesTable.insert(categoryName <- "Spices"),
                    productCategoriesTable.insert(categoryName <- "Bread"),
                    productCategoriesTable.insert(categoryName <- "Dairy"),
                    productCategoriesTable.insert(categoryName <- "Nuts seeds"),
                    productCategoriesTable.insert(categoryName <- "Others")
                ]
                
                for query in categoriesSql {
                    do {
                        try dbConnection.run(query)
                    } catch {
                        print("Error creating categories records: \(error)")
                    }
                }
            }
        } catch {
            print("Error counting categories records: \(error)")
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
            print("Error creating dish categories table: \(error)")
        }
        
        let selectCategoriesIfNotExists = dishCategoriesTable.count
        do {
            let categoryCount = try dbConnection.scalar(selectCategoriesIfNotExists)
            
            if categoryCount == 0 {
                let categoriesSql = [
                    dishCategoriesTable.insert(categoryName <- "Breakfast"),
                    dishCategoriesTable.insert(categoryName <- "Lunch"),
                    dishCategoriesTable.insert(categoryName <- "Dinner"),
                ]
                
                for query in categoriesSql {
                    do {
                        try dbConnection.run(query)
                    } catch {
                        print("Error creating dish categories records: \(error)")
                    }
                }
            }
        } catch {
            print("Error counting cdish ategories records: \(error)")
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
            table.foreignKey(categoryId, references: productCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createProductsTableQuery)
        } catch {
            print("Error creating products table: \(error)")
        }
    }
    
    // Existing code for creating and populating Categories and Products tables
    // ...
    
    func createDishTable() {
        let createDishTableQuery = dishTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(name, unique: true)
            table.column(photo)
            table.column(categoryId)
            table.foreignKey(categoryId, references: dishCategoriesTable, id, update: .cascade, delete: .cascade)
        }
        
        do {
            try dbConnection.run(createDishTableQuery)
        } catch {
            print("Error creating dish table: \(error)")
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
            print("Error creating product_amount table: \(error)")
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
            print("Error creating products_to_buy table: \(error)")
        }
    }
    
    
    func insertProduct(product: Product) {
        let insertQuery = productsTable.insert(
            name <- product.name,
            photo <- product.photo,
            calories <- product.calories,
            protein <- product.protein,
            fat <- product.fat,
            carbo <- product.carbo,
            categoryId <- product.category.id!
        )
        
        do {
            let productId = try dbConnection.run(insertQuery)
            product.id = Int(productId)
        } catch {
            print("Error inserting record: \(error)")
        }
    }
    
    func updateProduct(product: Product){
        do {
            if let _ = try dbConnection.pluck(productsTable.filter(id == product.id!)) {
                
                let updateProductQuery = productsTable.filter(id == product.id!)
                    .update(name <- product.name,
                            calories <- product.calories,
                            protein <- product.protein,
                            fat <- product.fat,
                            carbo <- product.carbo,
                            photo <- product.photo,
                            categoryId <- product.category.id!)
                do {
                    try dbConnection.run(updateProductQuery)
                } catch {
                    print("Error updating product: \(error)")
                }
            }
        } catch {
            print("Product not found id: \(product.id!)")
        }
    }
    
    
    func removeProduct(product: Product) {
        let deleteQuery = productsTable.filter(id == product.id!).delete()
        
        do {
            try dbConnection.run(deleteQuery)
        } catch {
            print("Error removing product: \(error)")
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
                let carbo = row[productsTable[carbo]]
                let categoryId = row[productCategoriesTable[id]] // Use the alias directly instead of categoryId
                let categoryName = row[productCategoriesTable[categoryName]]
                
                // Convert Blob to UIImage
                let photoData = Data.fromDatatypeValue(photoBlob)
                let photo = UIImage(data: photoData)
                
                let category = Category(id: categoryId, name: categoryName)
                let product = Product(id: dbId, name: name, photo: photo!, kcal: kcal, carbo: carbo, fat: fat, protein: protein, category: category)
                products.append(product)
            }
        } catch {
            print("Error selecting records: \(error)")
        }
        
        return products
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
            print("Error selecting records: \(error)")
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
            print("Error selecting records: \(error)")
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
                let dishCategoryId = dishRow[dishCategoriesTable[id]]
                let dishCategoryName = dishRow[dishCategoriesTable[categoryName]]
                let dishCategory = Category(id: dishCategoryId, name: dishCategoryName)
                let productAmountsForDish = fetchProductsAmountForDish(dishIdToSearch: dishId)
                
                let photoData = Data.fromDatatypeValue(dishPhoto)
                let photo = UIImage(data: photoData)
                
                dishes.append(Dish(id: dishId, name: dishName, photo: photo!, productAmounts: productAmountsForDish, category: dishCategory))
                
            }
        } catch {
            print("Error fetching dish: \(error)")
        }
        return dishes
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
                let productPhotoBlob = productRow[productsTable[photo]]
                let productKcal = productRow[productsTable[calories]]
                let productProtein = productRow[productsTable[protein]]
                let productFat = productRow[productsTable[fat]]
                let productCarbo = productRow[productsTable[carbo]]
                let productCategoryId = productRow[productCategoriesTable[id]]
                let productCategoryName = productRow[productCategoriesTable[categoryName]]
                
                let dishAmount = productRow[productAmountTable[amount]]
                
                let photoData = Data.fromDatatypeValue(productPhotoBlob)
                let photo = UIImage(data: photoData)
                
                let productCategory = Category(id: productCategoryId, name: productCategoryName)
                let product = Product(id: productId, name: productName, photo: photo!, kcal: productKcal, carbo: productCarbo, fat: productFat, protein: productProtein, category: productCategory)
                
                let productAmount = ProductAmount(product: product, amount: dishAmount)
                productAmountsForDish.append(productAmount)
            }
        } catch {
            print("Error fetching dish (\(dishId): \(error)")
        }
        
        return productAmountsForDish
    }
    
    func insertProductAmountForDish(dish: Dish){
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
            print("Error inserting product amount: \(error)")
        }
    }
    
    func removeProductAmountForDish(dish: Dish){
        let deleteProductAmountQuery = productAmountTable.filter(dishId == dish.id!).delete()
 
        do {
            try dbConnection.run(deleteProductAmountQuery)
        } catch {
            print("Error removing product amounts: \(error)")
        }
    }
    
    func insertDish(dish: Dish) {
        
        let insertDishQuery = dishTable.insert(
            name <- dish.name,
            photo <- dish.photo,
            categoryId <- dish.category.id!)
        do {
            dish.id = try Int(dbConnection.run(insertDishQuery))
            insertProductAmountForDish(dish: dish)
        } catch {
            print("Error inserting dish: \(error)")
        }
    }
    
    func updateDish(dish: Dish){
        do {
            if let _ = try dbConnection.pluck(dishTable.filter(id == dish.id!)) {
                
                let updateDishQuery = dishTable.filter(id == dish.id!)
                    .update(name <- dish.name,
                            photo <- dish.photo,
                            categoryId <- dish.category.id!)
                do {
                    try dbConnection.run(updateDishQuery)
                    removeProductAmountForDish(dish: dish)
                    insertProductAmountForDish(dish: dish)
                } catch {
                    print("Error updating dish: \(error)")
                }
            }
        } catch {
            print("Dish not found id: \(dish.id!)")
        }
    }
    
    func removeDish(dish: Dish) {
        let deleteQueryDish = dishTable.filter(id == dish.id!).delete()
 
        do {
            try dbConnection.run(deleteQueryDish)
        } catch {
            print("Error removing product: \(error)")
        }
    }
    
    func addDishToShoppingList(dish: Dish){
        dish.productAmounts.forEach { productAmount in
            addProductToShoppingList(productToBuy: productAmount)
        }
    }
    
    func addProductToShoppingList(productToBuy: ProductAmount) {
        do {
            if let existingProduct = try dbConnection.pluck(productsToBuyTable.filter(productId == productToBuy.product.id!)) {
                // Product exists, perform an update
                let updateQuery = productsToBuyTable.filter(productId == productToBuy.product.id!)
                    .update(amount <- existingProduct[amount] + productToBuy.amount)
                try dbConnection.run(updateQuery)
            } else {
                try dbConnection.run(productsToBuyTable.insert(productId <- productToBuy.product.id!,
                                                               amount <- productToBuy.amount))
            }
        } catch {
            print("Error adding/updating product: \(error)")
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
                let productPhotoBlob = row[productsTable[photo]]
                let productKcal = row[productsTable[calories]]
                let productProtein = row[productsTable[protein]]
                let productFat = row[productsTable[fat]]
                let productCarbo = row[productsTable[carbo]]
                let productCategoryId = row[productCategoriesTable[id]]
                let productCategoryName = row[productCategoriesTable[categoryName]]
                
                let productToBuyAmount = row[productsToBuyTable[amount]]
                
                let photoData = Data.fromDatatypeValue(productPhotoBlob)
                let photo = UIImage(data: photoData)
                
                let product = Product(id: productId, name: productName, photo: photo!, kcal: productKcal, carbo: productCarbo, fat: productFat, protein: productProtein, category: Category(id: productCategoryId, name: productCategoryName))
                
                let productAmount = ProductAmount(product: product, amount: productToBuyAmount)
                productsToBuy.append(productAmount)
            }
            
        } catch {
            print("Error fetching products to buy: \(error)")
        }
        return productsToBuy
    }
    
    func removeProductToBuy(productToBuy: ProductAmount) {
        let deleteQueryProductToBuy = productsToBuyTable.filter(productId == productToBuy.product.id!).delete()
        
        do {
            try dbConnection.run(deleteQueryProductToBuy)
    
        } catch {
            print("Error removing product: \(error)")
        }
    }
}
        
