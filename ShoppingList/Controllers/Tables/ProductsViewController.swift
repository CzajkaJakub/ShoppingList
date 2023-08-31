import UIKit

class ProductsViewController: UIViewController {
    
    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()
    
    private var allProductsGroupedByCategory: [[Product]] {
        let groupedProducts = Dictionary(grouping: Product.products, by: { $0.category.name })
        return groupedProducts.values.sorted(by: { $0[0].category.name < $1[0].category.name })
    }
    
    private var filteredProductsGroupedByCategory: [[Product]] = []
    
    private lazy var addProductButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProductView))
    }()
    
    private lazy var searchButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchAlert))
    }()
    
    private lazy var clearSearchButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clearSearchTerm))
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearSearchTerm()
        self.title = "Products"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsTable.delegate = self
        productsTable.dataSource = self
        
        navigationItem.rightBarButtonItems = [addProductButton, searchButton]
        navigationItem.leftBarButtonItems = [clearSearchButton]
        view.addSubview(productsTable)
        
        // Add a long-press gesture recognizer to the table view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(editProductAction(_:)))
        productsTable.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        productsTable.frame = view.bounds
    }
    
    @objc private func reloadProducts() {
        productsTable.reloadData()
    }
    
    @objc private func clearSearchTerm() {
        self.filterProducts(searchTerm: nil)
    }
    
    @objc private func addProductView() {
        navigationController?.pushViewController(AddProductViewController(), animated: true)
    }
    
    private func openProductViewController(editMode: Bool, product: Product){
        let editProductVC = AddProductViewController()

        if editMode == true {
            editProductVC.editedProduct = product
        }
        
        editProductVC.nameTextField.text = product.name
        editProductVC.carboTextField.text = String(product.carbo)
        editProductVC.kcalTextField.text = String(product.calories)
        editProductVC.fatTextField.text = String(product.fat)
        editProductVC.proteinTextField.text = String(product.protein)
        editProductVC.weightOfPieceTextField.text = product.weightOfPiece != nil ? String(product.weightOfPiece!) : nil
        editProductVC.selectedPhoto = UIImage(data: Data(product.photo.bytes))
        editProductVC.selectedOption = product.category
        editProductVC.reloadPhoto()
        navigationController?.pushViewController(editProductVC, animated: true)
    }
    
    @objc func editProductAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: productsTable)
            
            if let indexPath = productsTable.indexPathForRow(at: point) {
                let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
                
                let alertController = UIAlertController(title: "Options", message: "Choose an action:", preferredStyle: .actionSheet)
                
                let editAction = UIAlertAction(title: "Edit", style: .default) { (_) in
                    
                    self.openProductViewController(editMode: true, product: product)
                }
                
                let addNewAction = UIAlertAction(title: "Copy", style: .default) { (_) in
                    self.openProductViewController(editMode: false, product: product)
                }
                
                
                let eatProductAction = UIAlertAction(title: "Eat product", style: .default) { (_) in
                    
                    let amountAlert = UIAlertController(title: "Enter Amount", message: nil, preferredStyle: .alert)
                    amountAlert.addTextField { textField in
                        textField.placeholder = "Enter Amount (grams)"
                        textField.keyboardType = .decimalPad
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                        
                        let passedValueText = amountAlert.textFields?.first?.text!
                        if let passedValue = StringUtils.convertTextFieldToDouble(stringValue: passedValueText!) {
                            
                            let productAmount = ProductAmount(product: product, amount: passedValue)
                            let eatItem = EatHistoryItem(productAmount: productAmount)
                            EatHistoryItem.addItemToEatHistory(eatItem: eatItem)
                            Toast.showToast(message: "\(product.name) was eaten! (\(productAmount.amount) grams)", parentView: self!.view)
                            
                        } else {
                            Toast.showToast(message: "Wrong value text!", parentView: self!.view)
                        }
                    }
                    
                    amountAlert.addAction(cancelAction)
                    amountAlert.addAction(addAction)
                    self.present(amountAlert, animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(eatProductAction)
                alertController.addAction(editAction)
                alertController.addAction(addNewAction)
                alertController.addAction(cancelAction)
            
                present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    @objc func showSearchAlert() {
        let alertController = UIAlertController(title: "Search", message: "Enter a search term", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Search term"
        }

        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            if let searchTerm = alertController.textFields?.first?.text {
                self?.filterProducts(searchTerm: searchTerm)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func filterProducts(searchTerm: String?) {
        if searchTerm == nil || searchTerm!.isEmpty {
            filteredProductsGroupedByCategory = allProductsGroupedByCategory
        } else {
            filteredProductsGroupedByCategory = allProductsGroupedByCategory.map { products in
                products.filter { product in
                    let productName = product.name.lowercased()
                    return productName.contains(searchTerm!.lowercased())
                }
            }.filter { !$0.isEmpty }
        }
        productsTable.reloadData()
    }
}

extension ProductsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredProductsGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProductsGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewComponent.tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewComponent.createHeaderForTable(tableView: tableView, headerName: filteredProductsGroupedByCategory[section][0].category.name)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewComponent.headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(product.name)"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = .gray
        detailsLabel.text = """
            Kcal: \(product.calories)  |  Carbs: \(product.carbo)  |  Fat: \(product.fat)  |  Protein: \(product.protein)
            """
        cell.contentView.addSubview(detailsLabel)
        
        let productImageView = TableViewComponent.createImageView(photoInCell: product.photo)
        cell.contentView.addSubview(productImageView)
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
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
    
    private func removeProduct(at indexPath: IndexPath) {
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        Product.removeProduct(product: product)
        reloadProducts()
    }
    
    private func addProductToShoppingList(at indexPath: IndexPath, amount: Double) {
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        let productAmount = ProductAmount(product: product, amount: amount)
        ProductAmount.addProductTuBuy(productAmount: productAmount)
    }
}
