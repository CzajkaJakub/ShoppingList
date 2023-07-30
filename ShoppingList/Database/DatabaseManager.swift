//
//  DatabaseManager.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import Foundation
import SQLite
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
        print(try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
        print(fileURL)
        
        do {
            dbConnection = try Connection(fileURL.path)
            createProductCategoriesTableAndInsertData()
            createProductTable()
            createDishTable()
            createProductsToBuyTable()
            createDishCategoriesTableAndInsertData()
        } catch {
            print("Error opening database: \(error)")
            fatalError("Failed to open database")
        }
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
            table.foreignKey(categoryId, references: dishCategoriesTable, id, update: .cascade, delete: .setNull)
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
            table.column(calories)
            table.column(fat)
            table.column(carbo)
            table.column(protein)
            table.column(categoryId)
            table.foreignKey(categoryId, references: dishCategoriesTable, id, update: .cascade, delete: .setNull)
        }
        
        do {
            try dbConnection.run(createDishTableQuery)
        } catch {
            print("Error creating dish table: \(error)")
        }
        
        let createProductAmountTableQuery = productAmountTable.create(ifNotExists: true) { table in
            table.column(id)
            table.column(productId)
            table.column(amount)
            table.foreignKey(id, references: dishTable, id, update: .cascade, delete: .cascade)
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
            photo <- product.photo!,
            calories <- product.calories,
            protein <- product.protein,
            fat <- product.fat,
            carbo <- product.carbo,
            categoryId <- product.category.categoryId
        )
        
        do {
            let _ = try dbConnection.run(insertQuery)
        } catch {
            print("Error inserting record: \(error)")
        }
    }
    
    
    func removeProduct(product: Product) {
        let deleteQuery = productsTable.filter(id == product.dbId).delete()
        
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
                
                let category = Category(categoryId: categoryId, categoryName: categoryName)
                let product = Product(dbId: dbId, name: name, photo: photo!, kcal: kcal, carbo: carbo, fat: fat, protein: protein, category: category)
                products.append(product)
            }
        } catch {
            print("Error selecting records: \(error)")
        }
        
        return products
    }
    
    func fetchProductCategory() -> [Category] {
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
                
                let category = Category(categoryId: categoryId, categoryName: categoryName)
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
                
                let category = Category(categoryId: categoryId, categoryName: categoryName)
                categories.append(category)
            }
        } catch {
            print("Error selecting records: \(error)")
        }
        
        return categories
    }
    
    // Existing code for inserting and fetching products
    // ...
    func fetchDishes() -> [Dish] {
        var dishes: [Dish] = []
        do {
            let query = dishTable.join(productAmountTable, on: dishTable[id] == productAmountTable[id])
                .join(productsTable, on: productAmountTable[productId] == productsTable[id])
                .join(productCategoriesTable, on: productsTable[categoryId] == productCategoriesTable[id])
                .join(dishCategoriesTable, on: dishTable[categoryId] == dishCategoriesTable[id])
                .select(dishTable[*], productsTable[*], productAmountTable[*], productCategoriesTable[*], dishCategoriesTable[*])
                .order(dishTable[name])
            
            var currentDish: Dish?
            var productAmounts: [ProductAmount] = []
            
            for row in try dbConnection.prepare(query) {
                let dishId = row[dishTable[id]]
                let dishName = row[dishTable[name]]
                let dishPhoto = row[dishTable[photo]]
                let dishCalories = row[dishTable[calories]]
                let dishFat = row[dishTable[fat]]
                let dishCarbo = row[dishTable[carbo]]
                let dishProteins = row[dishTable[protein]]
                
                let productId = row[productsTable[id]]
                let productName = row[productsTable[name]]
                let productPhotoBlob = row[productsTable[photo]]
                let productKcal = row[productsTable[calories]]
                let productProtein = row[productsTable[protein]]
                let productFat = row[productsTable[fat]]
                let productCarbo = row[productsTable[carbo]]
                let productCategoryId = row[productCategoriesTable[id]] // Use the alias directly instead of categoryId
                let productCategoryName = row[productCategoriesTable[categoryName]]
                
                let dishAmount = row[productAmountTable[amount]]
                
                let dishCategoryId = row[dishCategoriesTable[id]]
                let dishCategory = row[dishCategoriesTable[categoryName]]
                
                if currentDish == nil || currentDish!.id != dishId {
                    if var currentDish = currentDish {
                        currentDish.productAmounts = productAmounts
                        dishes.append(currentDish)
                    }
                    
                    // Convert Blob to UIImage
                    let photoData = Data.fromDatatypeValue(dishPhoto)
                    let photo = UIImage(data: photoData)
                    
                    currentDish = Dish(id: dishId, name: dishName, photo: photo!, calories: dishCalories, carbo: dishCarbo, fat: dishFat, protein: dishProteins, productAmounts: [], category: Category(categoryId: dishCategoryId, categoryName: dishCategory))
                    productAmounts = []
                }
                
                let photoData = Data.fromDatatypeValue(productPhotoBlob)
                let photo = UIImage(data: photoData)
                
                let product = Product(dbId: productId, name: productName, photo: photo!, kcal: productKcal, carbo: productCarbo, fat: productFat, protein: productProtein, category: Category(categoryId: productCategoryId, categoryName: productCategoryName))
                
                let productAmount = ProductAmount(product: product, amount: dishAmount)
                productAmounts.append(productAmount)
            }
            
            if var currentDish = currentDish {
                currentDish.productAmounts = productAmounts
                dishes.append(currentDish)
            }
        } catch {
            print("Error fetching dishes: \(error)")
        }
        
        return dishes
    }
    
    func insertDish(dish: Dish) {
        // Insert the dish into the dish table
        let insertDishQuery = dishTable.insert(
            name <- dish.name,
            photo <- dish.photo!,
            calories <- dish.calories,
            fat <- dish.fat,
            carbo <- dish.carbo,
            protein <- dish.proteins,
            categoryId <- dish.category.categoryId
        )
        
        do {
            let dishId = try dbConnection.run(insertDishQuery)
            // Insert the product amounts into the product_amount table
            for productAmount in dish.productAmounts {
                let insertProductAmountQuery = productAmountTable.insert(
                    self.id <- Int(dishId),
                    self.productId <- productAmount.product.dbId,
                    amount <- productAmount.amount
                )
                try dbConnection.run(insertProductAmountQuery)
            }
        } catch {
            print("Error inserting dish: \(error)")
        }
    }
    
    func removeDish(dish: Dish) {
        let deleteQueryDish = dishTable.filter(id == dish.id).delete()
        let deleteQueryProductAmount = productAmountTable.filter(id == dish.id).delete()
        
        do {
            try dbConnection.run(deleteQueryDish)
            try dbConnection.run(deleteQueryProductAmount)
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
            if let existingProduct = try dbConnection.pluck(productsToBuyTable.filter(productId == productToBuy.product.dbId)) {
                // Product exists, perform an update
                let updateQuery = productsToBuyTable.filter(productId == productToBuy.product.dbId)
                    .update(amount <- existingProduct[amount] + productToBuy.amount)
                try dbConnection.run(updateQuery)
            } else {
                try dbConnection.run(productsToBuyTable.insert(productId <- productToBuy.product.dbId,
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
                
                let product = Product(dbId: productId, name: productName, photo: photo!, kcal: productKcal, carbo: productCarbo, fat: productFat, protein: productProtein, category: Category(categoryId: productCategoryId, categoryName: productCategoryName))
                
                let productAmount = ProductAmount(product: product, amount: productToBuyAmount)
                productsToBuy.append(productAmount)
            }
            
        } catch {
            print("Error fetching products to buy: \(error)")
        }
        return productsToBuy
    }
    
    func removeProductToBuy(productToBuy: ProductAmount) {
        let deleteQueryProductToBuy = productsToBuyTable.filter(productId == productToBuy.product.dbId).delete()
        
        do {
            try dbConnection.run(deleteQueryProductToBuy)
        } catch {
            print("Error removing product: \(error)")
        }
    }
}
        
