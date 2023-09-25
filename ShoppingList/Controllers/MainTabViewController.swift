import UIKit

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        loadDataFromDatabase()
        
        let vc1 = UINavigationController(rootViewController: ShoppingListViewController())
        vc1.view.backgroundColor = .systemBackground
        vc1.tabBarItem.image = UIImage(systemName: "cart")
        vc1.tabBarItem.title = Constants.shoppingList
        
        let vc2 = UINavigationController(rootViewController: ProductsViewController())
        vc2.view.backgroundColor = .systemBackground
        vc2.tabBarItem.image = UIImage(systemName: "folder.fill")
        vc2.tabBarItem.title = Constants.products
        
        let vc3 = UINavigationController(rootViewController: DishesViewController())
        vc3.view.backgroundColor = .systemBackground
        vc3.tabBarItem.image = UIImage(systemName: "folder.circle")
        vc3.tabBarItem.title = Constants.dishes
        
        let vc4 = UINavigationController(rootViewController: EatHistoryViewController())
        vc4.view.backgroundColor = .systemBackground
        vc4.tabBarItem.image = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
        vc4.tabBarItem.title = DateUtils.convertDateToMediumFormat(dateToConvert: Date())
        
        let vc5 = UINavigationController(rootViewController: RecipesViewController())
        vc5.view.backgroundColor = .systemBackground
        vc5.tabBarItem.image = UIImage(systemName: "cart")
        vc5.tabBarItem.title = DateUtils.convertRangeToShortFormat(monthToConvert: Date())
        
        setViewControllers([vc1, vc2, vc3, vc4, vc5], animated: true)
    }
    
    func loadDataFromDatabase() {
        do {
            Product.products = try DatabaseManager.shared.fetchProducts()
            Category.dishCategories = try DatabaseManager.shared.fetchDishCategories()
            Category.productCategories = try DatabaseManager.shared.fetchProductCategories()
            Dish.dishes = try DatabaseManager.shared.fetchDishes()
            ProductAmount.productsToBuy = try DatabaseManager.shared.fetchShoppingList()
        } catch {
            Alert.displayErrorAlert(message: "\(error)")
        }
    }
}

extension MainTabViewController  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return true
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.4, options: [.transitionCrossDissolve], completion: nil)
        }
        
        return true
    }
}
