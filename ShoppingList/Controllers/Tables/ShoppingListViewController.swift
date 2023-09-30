import UIKit

class ShoppingListViewController: UIViewController {
    
    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()
    
    private lazy var clearShoppingListButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearShoppingList))
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
        self.title = Constants.shoppingList
        navigationItem.rightBarButtonItems = [self.clearShoppingListButton]
        
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
    
    @objc private func clearShoppingList() {
        let clearShoppingListAction = UIAlertController(title: Constants.confirm, message: Constants.clearShoppingListMessage, preferredStyle: .alert)
        clearShoppingListAction.addAction(UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil))
        clearShoppingListAction.addAction(UIAlertAction(title: Constants.clear, style: .destructive, handler: { _ in
            ProductAmount.clearShoppingList()
            self.reloadProducts()
        }))
        present(clearShoppingListAction, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        
        let popupVC = PopUpModalViewController()
        popupVC.blobImageToDisplay = product.product.photo
        
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        self.present(popupVC, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let productAmounts = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(productAmounts.product.name)"
        cell.contentView.addSubview(nameLabel)
        
        let pieceAmountLabel = productAmounts.product.weightOfPiece != nil ? "\n\((productAmounts.amount / productAmounts.product.weightOfPiece!).rounded(toPlaces: 2)) szt." : ""
        let productAmountLabel = productAmounts.product.weightOfProduct != nil ? "\n\((productAmounts.amount / productAmounts.product.weightOfProduct!).rounded(toPlaces: 2)) opa." : ""
        let detailsLabel = UILabelPadding(insets: TableViewComponent.defaultLabelPadding, labelText: "\(productAmounts.amount) gr\(pieceAmountLabel)\(productAmountLabel)")
        
        detailsLabel.layer.cornerRadius = 10.0
        detailsLabel.layer.borderWidth = 1.8
        detailsLabel.layer.borderColor = UIColor.systemBlue.cgColor
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
        
        let removeProductAction = UIContextualAction(style: .normal, title: Constants.removeProduct) { [weak self] (action, view, completionHandler) in
            self?.removeProductToBuy(at: indexPath)
            completionHandler(true)
        }
        removeProductAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [removeProductAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func removeProductToBuy(at indexPath: IndexPath) {
        let productToRemove = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        ProductAmount.removeProductToBuy(productToBuy: productToRemove)
        reloadProducts()
    }
}

