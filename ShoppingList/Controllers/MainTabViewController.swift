import UIKit

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        loadDataFromDatabase()
        
        let vc1 = UINavigationController(rootViewController: ShoppingListViewController())
        vc1.view.backgroundColor = .systemBackground
        vc1.tabBarItem.image = UIImage(systemName: "cart")
        vc1.tabBarItem.title = "Shopping list"

        let vc2 = UINavigationController(rootViewController: ProductsViewController())
        vc2.view.backgroundColor = .systemBackground
        vc2.tabBarItem.image = UIImage(systemName: "folder.fill")
        vc2.tabBarItem.title = "Products"
        
        let vc3 = UINavigationController(rootViewController: DishesViewController())
        vc3.view.backgroundColor = .systemBackground
        vc3.tabBarItem.image = UIImage(systemName: "folder.circle")
        vc3.tabBarItem.title = "Dishes"
        
        setViewControllers([vc1, vc2, vc3], animated: true)
    }
    
    func loadDataFromDatabase() {
        Product.products = DatabaseManager.shared.fetchProducts()
        Category.dishCategories = DatabaseManager.shared.fetchDishCategories()
        Category.productCategories = DatabaseManager.shared.fetchProductCategories()
        Dish.dishes = DatabaseManager.shared.fetchDishes()
        ProductAmount.productsToBuy = DatabaseManager.shared.fetchProductsToBuy()
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
