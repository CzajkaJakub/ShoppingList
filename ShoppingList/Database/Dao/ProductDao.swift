//
//  ProductDao.swift
//  ShoppingList
//
//  Created by jczajka on 21/08/2024.
//

import Foundation
import SQLite
import SQLite3
import UIKit

class ProductDao: DatabaseSchemaHelper {
    
    private let dbManager: DatabaseSqlManager
    static let shared = ProductDao()

     init(dbManager: DatabaseSqlManager = .shared) {
         self.dbManager = dbManager
     }
    
    func removeProduct(product: Product) throws {
        let deleteQuery = dbManager.productsTable.filter(dbManager.id == product.id!).delete()
        try dbManager.deleteSql(deleteSql: deleteQuery, tableName: Constants.productsTable)
    }
    
    func insertProduct(product: Product) throws -> Int {
        
        let insertQuery = productsTable.insert(
            fat <- product.fat,
            name <- product.name,
            photo <- product.photo,
            carbo <- product.carbo,
            protein <- product.protein,
            calories <- product.calories,
            categoryId <- product.category.id!,
            weightOfPiece <- product.weightOfPiece,
            weightOfProduct <- product.weightOfProduct
        )
        
        return try Int(dbManager.insertSql(insertSql: insertQuery, tableName: Constants.productsTable))
    }
    
    func updateProduct(product: Product) throws {
        
        let updateProductQuery = productsTable.filter(id == product.id!)
            .update(name <- product.name,
                    fat <- product.fat,
                    photo <- product.photo,
                    carbo <- product.carbo,
                    protein <- product.protein,
                    calories <- product.calories,
                    categoryId <- product.category.id!,
                    weightOfPiece <- product.weightOfPiece,
                    weightOfProduct <- product.weightOfProduct)
        
        try dbManager.updateSql(updateSql: updateProductQuery, tableName: Constants.productsTable)
    }
    
    func fetchProducts() throws -> [Product] {
        var products: [Product] = []
        
        let selectQuery = productsTable
            .select(
                productsTable[*])
            .order(productsTable[name])
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.product){
            
            let fat = row[productsTable[fat]]
            let name = row[productsTable[name]]
            let carbo = row[productsTable[carbo]]
            let productId = row[productsTable[id]]
            let kcal = row[productsTable[calories]]
            let protein = row[productsTable[protein]]
            let photoBlob = row[productsTable[photo]]
            let categoryId = row[productsTable[categoryId]]
            let weightOfPiece = row[productsTable[weightOfPiece]]
            let weightOfProduct = row[productsTable[weightOfProduct]]
            
            let product = Product(id: productId, name: name, photo: photoBlob, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, weightOfProduct: weightOfProduct, category: ProductCategory(id: categoryId))
            
            products.append(product)
        }
  
        return products
    }
    
    func fetchProductById(productIdToFetch: Int) throws -> Product {
        
        let selectQuery = productsTable
            .select(productsTable[*]
            ).filter(productsTable[id] == productIdToFetch)
        
        for row in try dbManager.fetchSql(selectSql: selectQuery, tableName: Constants.product){
            
            let fat = row[productsTable[fat]]
            let name = row[productsTable[name]]
            let carbo = row[productsTable[carbo]]
            let productId = row[productsTable[id]]
            let kcal = row[productsTable[calories]]
            let protein = row[productsTable[protein]]
            let photoBlob = row[productsTable[photo]]
            let categoryId = row[productsTable[categoryId]]
            let weightOfPiece = row[productsTable[weightOfPiece]]
            let weightOfProduct = row[productsTable[weightOfProduct]]
            
            return Product(id: productId, name: name, photo: photoBlob, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, weightOfProduct: weightOfProduct, category: ProductCategory(id: categoryId))
        }
    }
}
