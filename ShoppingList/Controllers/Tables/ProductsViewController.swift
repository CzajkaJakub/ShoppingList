//
//  ProductsViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class ProductsViewController: UIViewController {
    
    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()
    
    private var productsGroupedByCategory: [[Product]] {
        let groupedProducts = Dictionary(grouping: Product.products, by: { $0.category.categoryName })
        return groupedProducts.values.sorted(by: { $0[0].category.categoryName < $1[0].category.categoryName })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadProducts()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadProducts()
        
        productsTable.delegate = self
        productsTable.dataSource = self
        
        view.addSubview(productsTable)
        }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        productsTable.frame = view.bounds
    }
    
    @objc private func reloadProducts() {
        productsTable.reloadData()
    }
}

extension ProductsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return productsGroupedByCategory.count
    }


    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return productsGroupedByCategory[section][0].category.categoryName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let product = productsGroupedByCategory[indexPath.section][indexPath.row]

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(product.name) (\(product.category.categoryName))"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = .gray
        detailsLabel.text = "Kcal: \(product.calories ?? 0) Carbs: \(product.carbo ?? 0) Fat: \(product.fat ?? 0) Protein \(product.protein ?? 0)"
        cell.contentView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
                
                nameLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                
                detailsLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                detailsLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
            ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addProductToShoppingListAction = UIContextualAction(style: .normal, title: "Add product to shopping list") { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to add this product to list?", preferredStyle: .alert)
            confirmationAlert.addTextField { textField in
                textField.placeholder = "Enter Amount"
                textField.keyboardType = .decimalPad
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let addAction = UIAlertAction(title: "Add", style: .destructive) { (_) in
                if let amountText = confirmationAlert.textFields?.first?.text,
                   let amount = Double(amountText) {
                    self?.addProductToShoppingList(at: indexPath, amount: amount)
                }
            }
            
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(addAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        addProductToShoppingListAction.backgroundColor = .blue // Customize the action button background color

        let configuration = UISwipeActionsConfiguration(actions: [addProductToShoppingListAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let removeDishAction = UIContextualAction(style: .normal, title: "Remove product") { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove this product?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (_) in
                self?.removeProduct(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(removeAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        removeDishAction.backgroundColor = .red // Customize the action button background color
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showProductDetail(for: indexPath)
    }
    
    private func showProductDetail(for indexPath: IndexPath) {
        let selectedProduct = productsGroupedByCategory[indexPath.section][indexPath.row]
        let productDetailViewController = ProductDetailViewController()
        productDetailViewController.product = selectedProduct
        navigationController?.pushViewController(productDetailViewController, animated: true)
    }

    private func removeProduct(at indexPath: IndexPath) {
        let product = productsGroupedByCategory[indexPath.section][indexPath.row]
        DatabaseManager.shared.removeProduct(product: product)
        Product.removeProduct(product: product)
        reloadProducts()
    }
    
    private func addProductToShoppingList(at indexPath: IndexPath, amount: Double) {
        let product = productsGroupedByCategory[indexPath.section][indexPath.row]
        let productAmount = ProductAmount(product: product, amount: amount)
        ProductAmount.addProductTuBuy(productAmount: productAmount)
        DatabaseManager.shared.addProductToShoppingList(productToBuy: productAmount)
    }
}
