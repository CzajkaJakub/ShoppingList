//
//  HomeViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class MainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        vc1.tabBarItem.image = UIImage(systemName: "house")
        
        let vc2 = UINavigationController(rootViewController: AddProductViewController())
        vc2.tabBarItem.image = UIImage(systemName: "plus")

        let vc3 = UINavigationController(rootViewController: ProductsViewController())
        vc3.tabBarItem.image = UIImage(systemName: "folder.fill")

        let vc4 = UINavigationController(rootViewController: AddDishViewController())
        vc4.tabBarItem.image = UIImage(systemName: "plus.app")

        let vc5 = UINavigationController(rootViewController: DishesViewController())
        vc5.tabBarItem.image = UIImage(systemName: "folder.circle")

        
        setViewControllers([vc1, vc2, vc3, vc4, vc5], animated: true)
    }
}
