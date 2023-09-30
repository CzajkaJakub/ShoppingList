import Foundation

class ProductAmount: NSCopying {
    var product: Product
    var amount: Double
    
    init(product: Product, amount: Double) {
        self.product = product
        self.amount = amount
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copyPA = ProductAmount(product: self.product, amount: self.amount)
        return copyPA
    }
    
    static var productsToBuy: [ProductAmount] = []
    
    static func removeProductToBuy(productToBuy: ProductAmount) {
        if let index = ProductAmount.productsToBuy.firstIndex(where: { $0.product.id == productToBuy.product.id }) {
            
            do {
                try DatabaseManager.shared.removeProductToBuy(productToBuy: productToBuy)
                ProductAmount.productsToBuy.remove(at: index)
            } catch {
                Alert.displayErrorAlert(message: "\(error)")
            }
        }
    }
    
    static func clearShoppingList() {
        do {
            try DatabaseManager.shared.removeAllProductsToBuy()
            ProductAmount.productsToBuy.removeAll()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func addProductToBuy(dish: Dish) {
        for productAmount in dish.productAmounts {
            addProductTuBuy(productAmount: productAmount)
        }
    }
    
    static func addProductTuBuy(productAmount: ProductAmount) {
        do {
            try DatabaseManager.shared.insertProductToShoppingList(productToBuy: productAmount)
            if let existingProductAmountIndex = ProductAmount.productsToBuy.firstIndex(where: { $0.product.id == productAmount.product.id }) {
                ProductAmount.productsToBuy[existingProductAmountIndex].amount += productAmount.amount
            } else {
                ProductAmount.productsToBuy.append(productAmount)
            }
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
    
    static func reloadProductsToBuyFromDatabase() {
        do {
            ProductAmount.productsToBuy = try DatabaseManager.shared.fetchShoppingList()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}
