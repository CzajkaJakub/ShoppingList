import Foundation

class Constants {
    
    //formats
    public static let dateFormat_MMMM_yyyy = "MMMM yyyy"
    
    //informations
    public static let error = "Wystapil blad!"
    public static let ok = "OK"
    
    //database
    public static let databaseName = "fitForYou.sqlite"
    
    // Database info
    public static let errorInsert = "Wystapil blad podczas zapisu"
    public static let errorUpdate = "Wystąpił błąd poczas aktualizacji"
    public static let errorRemove = "Wystapil blad podczas kasowania"
    public static let errorFetch = "Błąd podczas pobierania"
    public static let errorInsertOrUpdate = "Wystąpił błąd podczas tworzenia lub aktualizowania"
    public static let errorCreateDatabase = "Błąd podczas tworzenia bazy danych"
    
    public static let dish = "posiłek"
    public static let recipe = "paragon"
    public static let product = "produkt"
    public static let productAmount = "ilość produktów"
    public static let historyItem = "historyczny posiłek"
    public static let productToBuy = "produkt do kupienia"
    public static let productCategory = "Kategoria produktu"
    public static let productForDish = "produkt dania"
    public static let dishCategory = "Kategoria dania"
    public static let eatHistoryItem = "Historia zjedzonych posiłków"
    public static let eatHistory = "Historia posiłków"
    
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
        "Alkohole",
        "Pasty",
        "Inne"
    ]
    
    // Kategorie dań
    static let dishCategories = [
        "Śniadanie",
        "Obiad",
        "Kawa",
        "Kolacja"
    ]
}
