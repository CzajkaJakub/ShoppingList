//
//  HomeViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class ShoppingListViewController: UIViewController {

    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()
    
    private var productsToBuyGroupedByCategory: [[ProductAmount]] {
        let groupedProducts = Dictionary(grouping: ProductAmount.productsToBuy, by: { $0.product.category.categoryName })
        return groupedProducts.values.sorted(by: { $0[0].product.category.categoryName < $1[0].product.category.categoryName })
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

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return productsToBuyGroupedByCategory.count
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return productsToBuyGroupedByCategory[section].count
     }

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return productsToBuyGroupedByCategory[section][0].product.category.categoryName
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let productAmounts = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        
        let productImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFit
                imageView.layer.cornerRadius = 16
                imageView.clipsToBounds = true
            if let productPhoto = productAmounts.product.photo {
                    let photoData = Data.fromDatatypeValue(productPhoto)
                    let photo = UIImage(data: photoData)
                    imageView.image = photo
                }
                return imageView
            }()
        cell.contentView.addSubview(productImageView)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(productAmounts.product.name) (\(productAmounts.product.category.categoryName))"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = .gray
        detailsLabel.text = "Amount: \(productAmounts.amount ?? 0)"
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

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let removeDishAction = UIContextualAction(style: .normal, title: "Remove product") { [weak self] (action, view, completionHandler) in
            self?.removeProductToBuy(at: indexPath)
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        removeDishAction.backgroundColor = .red // Customize the action button background color
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }

    func removeProductToBuy(at indexPath: IndexPath) {
        let productToRemove = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        DatabaseManager.shared.removeProductToBuy(productToBuy: productToRemove)
        ProductAmount.removeProductToBuy(productToBuy: productToRemove)
        reloadProducts()
    }
}

