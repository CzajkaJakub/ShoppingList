import Foundation

class Constants {
    
    public static let dateFormat_MMMM_yyyy = "MMMM yyyy"
    public static let error = "Wystapil blad!"
    public static let ok = "OK"
    
    // Database errors
    public static let errorInsertDish = "Wystapil blad podczas zapisu nowego dania"
    public static let errorRemoveProductAmount = "Wystapil blad podczas kasowania produktow dla dania"

    
    // Tables
    static let productsTable = "products"
    static let productCategoriesTable = "product_category"
    static let dishCategoriesTable = "dish_category"
    static let productsToBuyTable = "products_to_buy"
    static let productAmountTable = "product_amount"
    static let eatHistoryTable = "eat_history"
    static let recipeTable = "recipes"
    static let dishTable = "dish"
    
    //Foreign keys columns
    static let categoryId = "category_id"
    static let productId = "product_id"
    static let dishId = "dish_id"
    
    // Columns
    static let id = "id"
    static let name = "name"
    static let photo = "photo"
    static let calories = "calories"
    static let protein = "protein"
    static let fat = "fat"
    static let carbo = "carbo"
    static let categoryName = "category_name"
    static let amount = "amount"
    static let weightOfPiece = "weight_of_piece"
    static let dateTime = "date_time"
    static let description = "description"
    static let favourite = "favourite"
    
    // Kategorie produktów
    static let productCategories = [
        "Warzywa",
        "Owoce",
        "Mięso",
        "Ziarna",
        "Tłuszcze",
        "Słodkie",
        "Przyprawy",
        "Produkty zbożowe",
        "Mleko i nabiał",
        "Napoje",
        "Chemia gospodarcza",
        "Owoce morza",
        "Pasty",
        "Inne"
    ]
    
    // Kategorie dań
    static let dishCategories = [
        "Śniadanie",
        "Obiad",
        "Kolacja"
    ]
}
