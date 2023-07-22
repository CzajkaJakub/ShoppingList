//
//  ProductsViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class ProductsViewController: UIViewController {
    
    private var products: [Product] = []
    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()

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
        products = DatabaseManager.shared.fetchProducts()
        productsTable.reloadData()
    }
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        // Create a confirmation alert
        let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove this product?", preferredStyle: .alert)
        
        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmationAlert.addAction(cancelAction)
        
        // Add a remove action
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] (_) in
            // Remove the product
            if let cell = sender.superview?.superview as? UITableViewCell,
               let indexPath = self!.productsTable.indexPath(for: cell) {
                DatabaseManager.shared.removeProduct(product: self!.products[indexPath.row])
                self!.reloadProducts()
            }
        }
        confirmationAlert.addAction(removeAction)
        
        // Present the confirmation alert
        present(confirmationAlert, animated: true, completion: nil)
    }
}

extension ProductsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let product = products[indexPath.row]
        
        let productImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFit
                imageView.layer.cornerRadius = 16
                imageView.clipsToBounds = true
                if let productPhoto = product.photo {
                    let photoData = Data.fromDatatypeValue(productPhoto)
                    let photo = UIImage(data: photoData)
                    imageView.image = photo
                }
                return imageView
            }()
        cell.contentView.addSubview(productImageView)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(product.name) (\(product.category.categoryName))"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = .gray
        detailsLabel.text = "Kcal: \(product.kcal ?? 0) Carbs: \(product.carbo ?? 0) Fat: \(product.fat ?? 0) Protein \(product.protein ?? 0)"
        cell.contentView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
                productImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                productImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                productImageView.widthAnchor.constraint(equalToConstant: 32),
                productImageView.heightAnchor.constraint(equalToConstant: 32),
                
                nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
                nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                
                detailsLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
                detailsLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
            ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addProductToShoppingListAction = UIContextualAction(style: .normal, title: "Add product to shopping list") { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to add this product to list?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let addAction = UIAlertAction(title: "Add", style: .destructive) { (_) in
                self?.addProductToShoppingList(at: indexPath)
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

    func removeProduct(at indexPath: IndexPath) {
        DatabaseManager.shared.removeProduct(product: products[indexPath.row])
        products.remove(at: indexPath.row)
        reloadProducts()
    }
    
    func addProductToShoppingList(at indexPath: IndexPath) {
        DatabaseManager.shared.addProductToShoppingList(product: products[indexPath.row])
    }
}
