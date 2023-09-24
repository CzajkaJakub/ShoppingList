import Foundation

class Constants {
    
    //formats
    public static let dateFormat_MMMM_yyyy = "MMMM yyyy"
    
    //informations
    public static let ok = "OK"
    public static let error = "Wystapil blad!"
    public static let removeProduct = "Skasuj produkt"
    public static let shoppingList = "Lista zakupów"
    public static let products = "Produkty"
    public static let chooseAction = "Wybierz akcję"
    public static let edit = "Edytuj"
    public static let copy = "Kopiuj"
    public static let grams = "Gram"
    public static let cancel = "Anuluj"
    public static let add = "Dodaj"
    public static let dash = "-"
    public static let productWeight = "Szt."
    public static let confirm = "Potwierdzenie"
    public static let enterAmount = "Wprowadź ilość"
    public static let enterAmountInGrams = "Wprowadź ilość w gramach"
    public static let archive = "Zarchiwizuj"
    public static let archiveMessage = "Czy na pewno chcesz zarchiwizować?"
    public static let addToShoppingListMessage = "Czy na pewno chcesz dodać do listy zakupów?"
    public static let eatProduct = "Oznacz produkt jako zjedzony"
    public static let fat = "Tłuszcz"
    public static let searchTerm = "Wprowadź nazwę"
    public static let carbo = "Węglowodany"
    public static let search = "Wyszukaj"
    public static let protein = "Białko"
    public static let calories = "Kalorie"
    public static let description = "Opis"
    public static let categoryName = "Nazwa kategorii"
    public static let weightOfPiece = "Waga sztuki"
    public static let weightOfProduct = "Waga produktu"
    public static let amountOfPortion = "Ilość porcji"
    public static let missingInformations = "Brak info."
    public static let enteredWrongDoubleValueMessage = "Wprowadzono złą wartość liczbową!"

    
    //database
    public static let databaseName = "fitForYou.sqlite"
    
    // Database info
    public static let errorFetch = "Błąd podczas pobierania"
    public static let errorInsert = "Wystapil blad podczas zapisu"
    public static let errorRemove = "Wystapil blad podczas kasowania"
    public static let errorUpdate = "Wystąpił błąd poczas aktualizacji"
    public static let errorArchive = "Wystąpił błąd poczas archiwizacji"
    public static let errorCreateDatabase = "Błąd podczas tworzenia bazy danych"
    public static let errorInsertOrUpdate = "Wystąpił błąd podczas tworzenia lub aktualizowania"
    
    public static let dish = "posiłek"
    public static let recipe = "paragon"
    public static let product = "produkt"
    public static let productForDish = "produkt dania"
    public static let dishCategory = "Kategoria dania"
    public static let eatHistory = "Historia posiłków"
    public static let productAmount = "ilość produktów"
    public static let historyItem = "historyczny posiłek"
    public static let productToBuy = "produkt do kupienia"
    public static let productCategory = "Kategoria produktu"
    public static let eatHistoryItem = "Historia zjedzonych posiłków"
    
    // Tables
    static let dishTable = "dish"
    static let recipeTable = "recipes"
    static let productsTable = "products"
    static let eatHistoryTable = "eat_history"
    static let productAmountTable = "product_amount"
    static let dishCategoriesTable = "dish_category"
    static let productsToBuyTable = "products_to_buy"
    static let productCategoriesTable = "product_category"
    
    //Foreign keys columns
    static let dishId = "dish_id"
    static let productId = "product_id"
    static let categoryId = "category_id"
    
    // Columns
    static let idColumn = "id"
    static let fatColumn = "fat"
    static let nameColumn = "name"
    static let carboColumn = "carbo"
    static let photoColumn = "photo"
    static let amountColumn = "amount"
    static let proteinColumn = "protein"
    static let caloriesColumn = "calories"
    static let archivedColumn = "archived"
    static let dateTimeColumn = "date_time"
    static let favouriteColumn = "favourite"
    static let descriptionColumn = "description"
    static let categoryNameColumn = "category_name"
    static let weightOfPieceColumn = "weight_of_piece"
    static let weightOfProductColumn = "weight_of_product"
    static let amountOfPortionColumn = "amount_of_portion"
    
    // Kategorie produktów
    static let productCategories = [
        "Inne",
        "Pasty",
        "Mięso",
        "Owoce",
        "Napoje",
        "Ziarna",
        "Słodkie",
        "Warzywa",
        "Alkohole",
        "Tłuszcze",
        "Przyprawy",
        "Owoce morza",
        "Mleko i nabiał",
        "Produkty zbożowe",
        "Chemia gospodarcza"
    ]
    
    // Kategorie dań
    static let dishCategories = [
        "Kawa",
        "Obiad",
        "Kolacja",
        "Śniadanie"
    ]
}