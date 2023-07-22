import UIKit

class MainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: ShoppingListViewController())
        vc1.view.backgroundColor = .systemBackground
        vc1.tabBarItem.image = UIImage(systemName: "cart")
        vc1.tabBarItem.title = "Shopping list"


        let vc2 = UINavigationController(rootViewController: AddProductViewController())
        vc2.view.backgroundColor = .systemBackground
        vc2.tabBarItem.image = UIImage(systemName: "plus")
        vc2.tabBarItem.title = "Add Product"

        let vc3 = UINavigationController(rootViewController: ProductsViewController())
        vc3.view.backgroundColor = .systemBackground
        vc3.tabBarItem.image = UIImage(systemName: "folder.fill")
        vc3.tabBarItem.title = "Products"

        let vc4 = UINavigationController(rootViewController: AddDishViewController())
        vc4.view.backgroundColor = .systemBackground
        vc4.tabBarItem.image = UIImage(systemName: "plus.app")
        vc4.tabBarItem.title = "Add Dish"

        let vc5 = UINavigationController(rootViewController: DishesViewController())
        vc5.view.backgroundColor = .systemBackground
        vc5.tabBarItem.image = UIImage(systemName: "folder.circle")
        vc5.tabBarItem.title = "Dishes"
        
        setViewControllers([vc1, vc2, vc3, vc4, vc5], animated: true)
    }
}
