import UIKit

class ShoppingListViewController: UIViewController {
    
    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()
    
    private var productsToBuyGroupedByCategory: [[ProductAmount]] {
        let groupedProducts = Dictionary(grouping: ProductAmount.productsToBuy, by: { $0.product.category.name })
        return groupedProducts.values.sorted(by: { $0[0].product.category.name < $1[0].product.category.name })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadProducts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Shopping list"
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewComponent.tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewComponent.createHeaderForTable(tableView: tableView, headerName: productsToBuyGroupedByCategory[section][0].product.category.name)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewComponent.headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let productAmounts = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(productAmounts.product.name)"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabelPadding(insets: TableViewComponent.defaultLabelPadding, labelText: "\(productAmounts.amount) gr")
        
        // Set up rounded border
        detailsLabel.layer.cornerRadius = 10.0 // Adjust the radius as needed for your design
        detailsLabel.layer.borderWidth = 1.8  // Width of the border
        detailsLabel.layer.borderColor = UIColor.systemBlue.cgColor // Color of the border
        cell.contentView.addSubview(detailsLabel)
  
        let productImageView = TableViewComponent.createImageView(photoInCell: productAmounts.product.photo)
        cell.contentView.addSubview(productImageView)
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
  
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

            detailsLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            detailsLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
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
        ProductAmount.removeProductToBuy(productToBuy: productToRemove)
        reloadProducts()
    }
}

