import Foundation
import SQLite
import UIKit

public class Recipe {
    
    var id: Int?
    var photo: Blob
    var dateTime: Date
    var amount: Double
    
    init(id: Int, dateValue: Int, amount: Double, photo: Blob) {
        self.id = id
        self.photo = photo
        self.amount = amount
        self.dateTime = DateUtils.convertDoubleToDate(dateNumberValue: dateValue)
    }
    
    init(date: Date, amount: Double, photo: UIImage) {
        self.id = nil
        self.dateTime = date
        self.amount = amount
        self.photo = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
    }
    
    static var recipes: [Recipe] = []
    
    static func addRecipe(recipe: Recipe) {
        do {
            try DatabaseManager.shared.insertRecipe(recipe: recipe)
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func reloadEatItemsByDate(searchDateFrom: Date, searchDateTo: Date) {
        do {
            Recipe.recipes = try DatabaseManager.shared.fetchRecipes(dateFrom: searchDateFrom.startOfDay, dateTo: searchDateTo.endOfDay)

        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func removeRecipe(recipe: Recipe) {
        if let index = Recipe.recipes.firstIndex(where: { $0.id == recipe.id }) {
            
            do {
                try DatabaseManager.shared.removeRecipe(recipe: recipe)
                Recipe.recipes.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
}
