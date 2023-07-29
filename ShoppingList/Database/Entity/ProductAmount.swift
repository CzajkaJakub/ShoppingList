import Foundation

struct ProductAmount {
    var product: Product
    var amount: Double
    
    static var productsToBuy: [ProductAmount] = []
    
    static func removeProductToBuy(productToBuy: ProductAmount) {
        if let index = ProductAmount.productsToBuy.firstIndex(where: { $0.product.dbId == productToBuy.product.dbId }) {
            ProductAmount.productsToBuy.remove(at: index)
        }
    }
    
    static func addProductToBuy(dish: Dish) {
        for productAmount in dish.productAmounts {
            if let existingProductAmountIndex = ProductAmount.productsToBuy.firstIndex(where: { $0.product.dbId == productAmount.product.dbId }) {
                ProductAmount.productsToBuy[existingProductAmountIndex].amount += productAmount.amount
            } else {
                ProductAmount.productsToBuy.append(productAmount)
            }
        }
    }
    
    static func addProductTuBuy(productAmount: ProductAmount) {
        if let existingProductAmountIndex = ProductAmount.productsToBuy.firstIndex(where: { $0.product.dbId == productAmount.product.dbId }) {
            ProductAmount.productsToBuy[existingProductAmountIndex].amount += productAmount.amount
        } else {
            ProductAmount.productsToBuy.append(productAmount)
        }
    }
}
