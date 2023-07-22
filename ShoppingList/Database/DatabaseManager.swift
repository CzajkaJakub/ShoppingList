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
    
    private var productsTable = Table("products")
    private var name = Expression<String>("name")
    private var photo = Expression<Blob>("photo")
    private var kcal = Expression<Double>("kcal")
    private var protein = Expression<Double>("protein")
    private var fat = Expression<Double>("fat")
    private var carbo = Expression<Double>("carbo")
    private var categoryId = Expression<Int>("category_id")
    
    private var categoriesTable = Table("categories")
    private var id = Expression<Int>("id")
    private var categoryName = Expression<String>("categoryName")
    
    // New table properties (Dish table)
    private var dishTable = Table("dish")
    private var dishId = Expression<Int>("id")
    private var dishPhoto = Expression<Blob>("photo")
    private var dishName = Expression<String>("name")
    private var dishCalories = Expression<Double>("calories")
    private var dishFat = Expression<Double>("fat")
    private var dishCarbo = Expression<Double>("carbo")
    private var dishProteins = Expression<Double>("proteins")
       
    private var productAmountTable = Table("product_amount")
    private var productId = Expression<Int>("product_id")
    private var dishAmount = Expression<Double>("amount")


    private init() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("shoppingList.sqlite")
        print(try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
        print(fileURL)

        do {
            dbConnection = try Connection(fileURL.path)
            createCategoriesTableAndInsertData()
            createProductTable()
            createDishTable()
        } catch {
            print("Error opening database: \(error)")
            fatalError("Failed to open database")
        }
    }

    func createCategoriesTableAndInsertData() {
        let createCategoriesTableQuery = categoriesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(categoryName, unique: true)
        }
                
        do {
            try dbConnection.run(createCategoriesTableQuery)
        } catch {
            print("Error creating categories table: \(error)")
        }
        
        let selectCategoriesIfNotExists = categoriesTable.count
        do {
            let categoryCount = try dbConnection.scalar(selectCategoriesIfNotExists)

            if categoryCount == 0 {
                let categoriesSql = [
                    categoriesTable.insert(categoryName <- "Vegetables"),
                    categoriesTable.insert(categoryName <- "Fruits"),
                    categoriesTable.insert(categoryName <- "Meat"),
                    categoriesTable.insert(categoryName <- "Seafood"),
                    categoriesTable.insert(categoryName <- "Grain"),
                    categoriesTable.insert(categoryName <- "Fat"),
                    categoriesTable.insert(categoryName <- "Sweets"),
                    categoriesTable.insert(categoryName <- "Legumes"),
                    categoriesTable.insert(categoryName <- "Spices"),
                    categoriesTable.insert(categoryName <- "Bread"),
                    categoriesTable.insert(categoryName <- "Dairy"),
                    categoriesTable.insert(categoryName <- "Nuts seeds"),
                    categoriesTable.insert(categoryName <- "Others")
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
    
    func createProductTable(){
        let foreignKeyQuery = """
            FOREIGN KEY (\(categoryId)) REFERENCES \(categoriesTable) (\(id)) ON DELETE SET NULL ON UPDATE CASCADE
        """

        let createProductsTableQuery = productsTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(name)
            table.column(photo)
            table.column(kcal)
            table.column(protein)
            table.column(fat)
            table.column(carbo)
            table.column(categoryId)
            table.foreignKey(categoryId, references: categoriesTable, id, update: .cascade, delete: .setNull)
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
            table.column(dishId, primaryKey: .autoincrement)
            table.column(dishName, unique: true)
            table.column(dishPhoto)
            table.column(dishCalories)
            table.column(dishFat)
            table.column(dishCarbo)
            table.column(dishProteins)
        }
        
        do {
            try dbConnection.run(createDishTableQuery)
        } catch {
            print("Error creating dish table: \(error)")
        }

        let createProductAmountTableQuery = productAmountTable.create(ifNotExists: true) { table in
            table.column(dishId)
            table.column(productId)
            table.column(dishAmount)
            table.foreignKey(dishId, references: dishTable, dishId, update: .cascade, delete: .cascade)
            table.foreignKey(productId, references: productsTable, id, update: .cascade, delete: .cascade)
        }

        do {
            try dbConnection.run(createProductAmountTableQuery)
        } catch {
            print("Error creating product_amount table: \(error)")
        }
    }


    func insertProduct(product: Product) {
        let insertQuery = productsTable.insert(
            name <- product.name,
            photo <- product.photo!,
            kcal <- product.kcal,
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
            .join(categoriesTable, on: productsTable[categoryId] == categoriesTable[id])
            .select(
                productsTable[id],
                productsTable[name],
                productsTable[photo],
                productsTable[kcal],
                productsTable[protein],
                productsTable[fat],
                productsTable[carbo],
                categoriesTable[id], // Use the alias directly instead of categoryId
                categoriesTable[categoryName]
            )
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let dbId = row[productsTable[id]]
                let name = row[productsTable[name]]
                let photoBlob = row[productsTable[photo]]
                let kcal = row[productsTable[kcal]]
                let protein = row[productsTable[protein]]
                let fat = row[productsTable[fat]]
                let carbo = row[productsTable[carbo]]
                let categoryId = row[categoriesTable[id]] // Use the alias directly instead of categoryId
                let categoryName = row[categoriesTable[categoryName]]
                
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
    
    func fetchProductById(_ productId: Int) -> Product? {
        let selectQuery = productsTable
            .join(categoriesTable, on: productsTable[categoryId] == categoriesTable[id])
            .filter(productsTable[id] == productId) // Add filter to select only the product with the given ID
            .select(
                productsTable[id],
                productsTable[name],
                productsTable[photo],
                productsTable[kcal],
                productsTable[protein],
                productsTable[fat],
                productsTable[carbo],
                categoriesTable[id], // Use the alias directly instead of categoryId
                categoriesTable[categoryName]
            )
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let dbId = row[productsTable[id]]
                let name = row[productsTable[name]]
                let photoBlob = row[productsTable[photo]]
                let kcal = row[productsTable[kcal]]
                let protein = row[productsTable[protein]]
                let fat = row[productsTable[fat]]
                let carbo = row[productsTable[carbo]]
                let categoryId = row[categoriesTable[id]] // Use the alias directly instead of categoryId
                let categoryName = row[categoriesTable[categoryName]]
                
                // Convert Blob to UIImage
                let photoData = Data.fromDatatypeValue(photoBlob)
                let photo = UIImage(data: photoData)
                
                let category = Category(categoryId: categoryId, categoryName: categoryName)
                let product = Product(dbId: dbId, name: name, photo: photo!, kcal: kcal, carbo: carbo, fat: fat, protein: protein, category: category)
                return product // Return the product immediately when found
            }
        } catch {
            print("Error selecting records: \(error)")
        }
        
        return nil // Return nil if the product with the given ID is not found
    }



    func fetchCategories() -> [Category] {
        var categories: [Category] = []

        let selectQuery = categoriesTable
            .select(
                categoriesTable[id], // Use the alias directly instead of categoryId
                categoriesTable[categoryName]
            )
        
        do {
            for row in try dbConnection.prepare(selectQuery) {
                let categoryId = row[categoriesTable[id]] // Use the alias directly instead of categoryId
                let categoryName = row[categoriesTable[categoryName]]
                
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
                let query = dishTable.join(productAmountTable, on: dishTable[dishId] == productAmountTable[dishId])
                    .join(productsTable, on: productAmountTable[productId] == productsTable[id])
                    .join(categoriesTable, on: productsTable[categoryId] == categoriesTable[id])
                    .select(dishTable[*], productsTable[*], productAmountTable[*], categoriesTable[*])
                
                var currentDish: Dish?
                var productAmounts: [ProductAmount] = []

                for row in try dbConnection.prepare(query) {
                    let dishId = row[dishTable[dishId]]
                    let dishName = row[dishTable[dishName]]
                    let dishPhoto = row[dishTable[dishPhoto]]
                    let dishCalories = row[dishTable[dishCalories]]
                    let dishFat = row[dishTable[dishFat]]
                    let dishCarbo = row[dishTable[dishCarbo]]
                    let dishProteins = row[dishTable[dishProteins]]

                    let productId = row[productsTable[id]]
                    let productName = row[productsTable[name]]
                    let productPhotoBlob = row[productsTable[photo]]
                    let productKcal = row[productsTable[kcal]]
                    let productProtein = row[productsTable[protein]]
                    let productFat = row[productsTable[fat]]
                    let productCarbo = row[productsTable[carbo]]
                    let productCategoryId = row[categoriesTable[id]] // Use the alias directly instead of categoryId
                    let productCategoryName = row[categoriesTable[categoryName]]
                    
                    let dishAmount = row[productAmountTable[dishAmount]]

                    if currentDish == nil || currentDish!.id != dishId {
                        if var currentDish = currentDish {
                            currentDish.productAmounts = productAmounts
                            dishes.append(currentDish)
                        }
                        
                        // Convert Blob to UIImage
                        let photoData = Data.fromDatatypeValue(dishPhoto)
                        let photo = UIImage(data: photoData)

                        currentDish = Dish(id: dishId, name: dishName, photo: photo!, calories: dishCalories, carbo: dishCarbo, fat: dishFat, protein: dishProteins, productAmounts: [])
                        productAmounts = []
                    }
                    
                    let photoData = Data.fromDatatypeValue(productPhotoBlob)
                    let photo = UIImage(data: photoData)

                    let product = Product(dbId: productId, name: productName, photo: photo!, kcal: productKcal, carbo: productCarbo, fat: productFat, protein: productProtein, category: Category(categoryName: productCategoryName))
                    
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
            dishName <- dish.name,
            dishPhoto <- dish.photo!,
            dishCalories <- dish.calories,
            dishFat <- dish.fat,
            dishCarbo <- dish.carbo,
            dishProteins <- dish.proteins
        )

        do {
            let dishId = try dbConnection.run(insertDishQuery)
            // Insert the product amounts into the product_amount table
            for productAmount in dish.productAmounts {
                let insertProductAmountQuery = productAmountTable.insert(
                    self.dishId <- Int(dishId),
                    self.productId <- productAmount.product.dbId,
                    dishAmount <- productAmount.amount
                )
                try dbConnection.run(insertProductAmountQuery)
            }
        } catch {
            print("Error inserting dish: \(error)")
        }
    }
    
    func removeDish(dish: Dish) {
        let deleteQueryDish = dishTable.filter(dishId == dish.id).delete()
        let deleteQueryProductAmount = productAmountTable.filter(dishId == dish.id).delete()
        
        do {
            try dbConnection.run(deleteQueryDish)
            try dbConnection.run(deleteQueryProductAmount)
        } catch {
            print("Error removing product: \(error)")
        }
    }
    
    func addDishToShoppingList(dish: Dish){
        
    }
}
        
