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
    
    private var selectedDate: Date = Date()
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
        self.title = Constants.products
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsTable.delegate = self
        productsTable.dataSource = self
        
        navigationItem.rightBarButtonItems = [addProductButton, searchButton]
        navigationItem.leftBarButtonItems = [clearSearchButton]
        view.addSubview(productsTable)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(holdProductActions(_:)))
        productsTable.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        productsTable.frame = view.bounds
    }
    
    @objc private func clearSearchTerm() {
        self.filterProducts(searchTerm: nil)
    }
    
    @objc private func addProductView() {
        navigationController?.pushViewController(AddProductViewController(), animated: true)
    }
    
    private func openProductViewController(product: Product){
        let editProductVC = AddProductViewController()
        editProductVC.editedProduct = product
        editProductVC.nameTextField.text = product.name
        editProductVC.carboTextField.text = String(product.carbo)
        editProductVC.kcalTextField.text = String(product.calories)
        editProductVC.fatTextField.text = String(product.fat)
        editProductVC.proteinTextField.text = String(product.protein)
        editProductVC.weightOfProductTextField.text = product.weightOfProduct != nil ? String(product.weightOfProduct!) : nil
        editProductVC.weightOfPieceTextField.text = product.weightOfPiece != nil ? String(product.weightOfPiece!) : nil
        editProductVC.selectedPhoto = UIImage(data: Data(product.photo.bytes))
        editProductVC.selectedOption = product.category
        editProductVC.reloadPhoto()
        navigationController?.pushViewController(editProductVC, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
    }
    
    @objc func holdProductActions(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: productsTable)
            
            if let indexPath = productsTable.indexPathForRow(at: point) {
                let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
                
                let alertController = UIAlertController(title: Constants.chooseAction, message: nil, preferredStyle: .actionSheet)
                
                let editAction = UIAlertAction(title: Constants.edit, style: .default) { (_) in
                    self.openProductViewController(product: product)
                }
                
                let eatProductAction = UIAlertAction(title: Constants.eatProduct, style: .default) { (_) in
                    
                    let amountAlert = UIAlertController(title: "\(Constants.enterAmountInGrams)\n", message: nil, preferredStyle: .alert)
                    
                    amountAlert.addTextField { textField in
                        textField.placeholder = Constants.enterAmount
                        textField.keyboardType = .decimalPad
                    }
                    
                    
                    let datePicker: UIDatePicker = {
                        let datePicker = UIDatePicker()
                        datePicker.datePickerMode = .date
                        datePicker.date = Date()
                        datePicker.translatesAutoresizingMaskIntoConstraints = false
                        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
                        return datePicker
                    }()
                    
                    amountAlert.view.addSubview(datePicker)
                    datePicker.topAnchor.constraint(equalTo: amountAlert.view.topAnchor, constant: 42).isActive = true
                    datePicker.centerXAnchor.constraint(equalTo: amountAlert.view.centerXAnchor).isActive = true
                    
                    let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
                    let addAction = UIAlertAction(title: Constants.add, style: .default) { [weak self] _ in
                        
                        let passedValueText = amountAlert.textFields?.first?.text!
                        if let passedValue = StringUtils.convertTextFieldToDouble(stringValue: passedValueText!) {
                            
                            let eatItem = EatHistory(dish: nil, product: product, amount: passedValue, eatDate: self!.selectedDate)
                            EatHistory.addItemToEatHistory(eatItem: eatItem)
                            
                        } else {
                            Toast.showToast(message: Constants.enteredWrongDoubleValueMessage, parentView: self!.view)
                        }
                    }
                    
                    amountAlert.addAction(cancelAction)
                    amountAlert.addAction(addAction)
                    self.present(amountAlert, animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
                
                alertController.addAction(editAction)
                alertController.addAction(eatProductAction)
                alertController.addAction(cancelAction)
            
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func showSearchAlert() {
        let alertController = UIAlertController(title: Constants.search, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = Constants.searchTerm
        }

        let searchAction = UIAlertAction(title: Constants.search, style: .default) { [weak self] _ in
            if let searchTerm = alertController.textFields?.first?.text {
                self?.filterProducts(searchTerm: searchTerm)
            }
        }

        let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        
        let popupVC = PopUpModalViewController()
        popupVC.blobImageToDisplay = product.photo
        
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        self.present(popupVC, animated: true)
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
        detailsLabel.font = UIFont.systemFont(ofSize: 11)
        detailsLabel.textColor = .gray
        detailsLabel.numberOfLines = 0
        detailsLabel.text = "\(Constants.calories): \(product.calories)  |  \(Constants.carbo): \(product.carbo)\n\(Constants.fat): \(product.fat)  |  \(Constants.protein): \(product.protein)"
        cell.contentView.addSubview(detailsLabel)
        
        let pieceAmountLabel = product.weightOfPiece != nil ? String(product.weightOfPiece!.rounded(toPlaces: 2)) : Constants.dash
        let productAmountLabel = product.weightOfProduct != nil ? String(product.weightOfProduct!.rounded(toPlaces: 2)) : Constants.dash
        let productDetailsLabel = UILabelPadding(insets: TableViewComponent.defaultLabelPadding, labelText: "\(pieceAmountLabel) \(Constants.grams)\n\(productAmountLabel) \(Constants.productWeight)")
        
        productDetailsLabel.layer.cornerRadius = 10.0
        productDetailsLabel.layer.borderWidth = 1.8
        productDetailsLabel.layer.borderColor = UIColor.systemBlue.cgColor
        cell.contentView.addSubview(productDetailsLabel)
        
        let productImageView = TableViewComponent.createImageView(photoInCell: product.photo)
        cell.contentView.addSubview(productImageView)
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            
            productDetailsLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            productDetailsLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            detailsLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            detailsLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let addProductToShoppingListAction = UIContextualAction(style: .normal, title: Constants.shoppingList) { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: Constants.confirm, message: Constants.addToShoppingListMessage, preferredStyle: .alert)
            confirmationAlert.addTextField { textField in
                textField.placeholder = Constants.enterAmount
                textField.keyboardType = .decimalPad
            }
            
            let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
            let addAction = UIAlertAction(title: Constants.add, style: .destructive) { (_) in
                if let amountText = confirmationAlert.textFields?.first?.text,
                   let amount = Double(amountText) {
                    self?.addProductToShoppingList(at: indexPath, amount: amount)
                }
            }
            
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(addAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true)
        }
        
        addProductToShoppingListAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [addProductToShoppingListAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeProductAction = UIContextualAction(style: .normal, title: Constants.remove) { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: Constants.confirm, message: Constants.removeMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: Constants.remove, style: .destructive) { (_) in
                self?.removeProduct(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(removeAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true)
        }
        
        removeProductAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [removeProductAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func removeProduct(at indexPath: IndexPath) {
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        Product.removeProduct(product: product)
        self.filterProducts(searchTerm: nil)
    }
    
    private func addProductToShoppingList(at indexPath: IndexPath, amount: Double) {
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        let productAmount = ProductAmount(product: product, amount: amount)
        ProductAmount.addProductTuBuy(productAmount: productAmount)
    }
}
