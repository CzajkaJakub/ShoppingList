import UIKit

class AddDishViewController: UIViewController, UITableViewDelegate {
    
    private var selectedProductsGroupedByCategory: [[ProductAmount]] = []
    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.translatesAutoresizingMaskIntoConstraints = false
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()
        
    private var imageViewHeightConstraint: NSLayoutConstraint?
    internal var selectedPhoto: UIImage!
    internal var selectedProducts: [ProductAmount] = []
    internal var selectedOption: Category!
    internal var editedDish: Dish!
    
    internal let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.dishName
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    internal let dishDescriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.description
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let dishImageView: UIImageView = {
        let dishImageView = UIImageView()
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.layer.cornerRadius = 12
        dishImageView.clipsToBounds = true
        return dishImageView
    }()
    
    internal let amountOfPortionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.amountOfPortion
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private let selectListTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.selectCategory
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveDish))
    }()
    
    private lazy var addProductButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProductButtonTapped))
    }()
    
    private lazy var clearButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearFields))
    }()
    
    private lazy var selectPhotoButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectPhoto))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 16
        
        if self.selectedOption == nil { self.selectedOption = Category.dishCategories.first }
        self.selectListTextField.text = selectedOption.name
        
        navigationItem.rightBarButtonItems = [selectPhotoButton, clearButton, addProductButton, saveButton]
        view.addSubview(productsTable)

        setupConstraints()
        
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureKeyboard)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSelectList))
        selectListTextField.addGestureRecognizer(tapGesture)
        selectListTextField.isUserInteractionEnabled = true
        
        
        productsTable.delegate = self
        productsTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadProducts()
    }
    
    private func setupConstraints() {
        
        let stackView = UIStackView(arrangedSubviews: [selectListTextField, nameTextField, dishDescriptionTextField, amountOfPortionTextField, dishImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = TableViewComponent.stackViewAxis
        stackView.spacing = TableViewComponent.stackViewSpacing
        
        view.addSubview(stackView)
            
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: TableViewComponent.detailsComponentMargin),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TableViewComponent.detailsComponentMargin),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TableViewComponent.detailsComponentMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -TableViewComponent.detailsComponentMargin),
            
            productsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsTable.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            productsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func showSelectList() {
        let selectList = UIPickerView()
        selectList.delegate = self
        selectList.dataSource = self
        
        let selectListActionSheet = UIAlertController(title: Constants.chooseAction, message: nil, preferredStyle: .actionSheet)
        selectListActionSheet.view.addSubview(selectList)
        
        selectList.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectList.leadingAnchor.constraint(equalTo: selectListActionSheet.view.leadingAnchor),
            selectList.trailingAnchor.constraint(equalTo: selectListActionSheet.view.trailingAnchor),
            selectList.topAnchor.constraint(equalTo: selectListActionSheet.view.topAnchor),
            selectList.bottomAnchor.constraint(equalTo: selectListActionSheet.view.bottomAnchor, constant: -44)
        ])
        
        selectListActionSheet.addAction(UIAlertAction(title: Constants.chooseAction, style: .cancel, handler: nil))
        present(selectListActionSheet, animated: true, completion: nil)
    }
    
    
    @objc private func selectPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let imageSourceAlert = UIAlertController(title: Constants.selectPhotoSource, message: nil, preferredStyle: .alert)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let librarySourceButton = UIAlertAction(title: Constants.library, style: .default) { [weak self] _ in
                imagePicker.sourceType = .photoLibrary
                self?.present(imagePicker, animated: true, completion: nil)
            }
            imageSourceAlert.addAction(librarySourceButton)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraSourceButton = UIAlertAction(title: Constants.camera, style: .default) { [weak self] _ in
                imagePicker.sourceType = .camera
                self?.present(imagePicker, animated: true, completion: nil)
            }
            imageSourceAlert.addAction(cameraSourceButton)
        }
        
        if imageSourceAlert.actions.isEmpty {
            Alert.displayErrorAlert(message: Constants.cameraOrLibraryNotAvailable)
            return
        }
        
        let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
        imageSourceAlert.addAction(cancelAction)
        
        self.present(imageSourceAlert, animated: true, completion: nil)
    }
    
    @objc private func saveDish() {
        
        guard let photo = selectedPhoto,
              let name = nameTextField.text,
              let category = selectedOption,
              let description = dishDescriptionTextField.text,
              let amountOfPortion = StringUtils.convertTextFieldToDouble(stringValue: amountOfPortionTextField.text!)
        else {
            Toast.showToast(message: Constants.fillEmptyFields, parentView: self.view)
            return
        }
        
        let photoBlob = try! PhotoData.convertUIImageToResizedBlob(imageToResize: photo)
        
        if editedDish != nil {
            let dishToUpdate = Dish(id: editedDish.id!, name: name, description: description, favourite: editedDish.favourite, photo: photoBlob, archived: false, amountOfPortion: amountOfPortion, productAmounts: selectedProducts, category: category)
            Dish.updateDish(dish: dishToUpdate)
        } else {
            let dishToSave = Dish(name: name, description: description, photo: photo, archived: false, amountOfPortion: amountOfPortion, productAmounts: selectedProducts, category: category)
            Dish.addDish(dish: dishToSave)
        }
        
        let alertController = UIAlertController(title: Constants.success, message: Constants.dishWasSaved, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.ok, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        clearFields()
    }
    
    @objc private func clearFields() {
        let alertController = UIAlertController(title: Constants.clearFields, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: Constants.clear, style: .destructive, handler: { _ in
            self.dishImageView.image = nil
            self.imageViewHeightConstraint?.isActive = false
            self.nameTextField.text = nil
            self.selectedPhoto = nil
            self.selectedProducts.removeAll()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func addProductButtonTapped() {
        let productSelectionVC = ProductSelectionViewController()
        productSelectionVC.delegate = self
        navigationController?.pushViewController(productSelectionVC, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func reloadPhoto(){
        dishImageView.image = selectedPhoto
        
        if let image = dishImageView.image {
            let maxAllowedHeight = UIScreen.main.bounds.height * 0.35
            let aspectRatio = image.size.width / image.size.height
            let imageViewHeight = min(view.frame.width / aspectRatio, maxAllowedHeight)
            
            imageViewHeightConstraint = dishImageView.heightAnchor.constraint(equalToConstant: imageViewHeight)
            imageViewHeightConstraint?.isActive = true
        }
    }
    
    @objc private func reloadProducts() {
        let groupedProducts = Dictionary(grouping: selectedProducts, by: { $0.product.category.name })
        selectedProductsGroupedByCategory = groupedProducts.values.sorted(by: { $0[0].product.category.name < $1[0].product.category.name })
        productsTable.reloadData()
    }
}

extension AddDishViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.dishCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.dishCategories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = Category.dishCategories[row]
        selectListTextField.text = selectedOption.name
    }
}


extension AddDishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedPhoto = image
            reloadPhoto()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension AddDishViewController: ProductSelectionDelegate {
    func didSelectProduct(_ product: Product, amount: Double) {
        selectedProducts.append(ProductAmount(product: product, amount: amount))
        reloadProducts()
    }
}

protocol ProductSelectionDelegate: AnyObject {
    func didSelectProduct(_ product: Product, amount: Double)
}

extension AddDishViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedProductsGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedProductsGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewComponent.tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewComponent.createHeaderForTable(tableView: tableView, headerName: selectedProductsGroupedByCategory[section][0].product.category.name)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewComponent.headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let productAmount = selectedProductsGroupedByCategory[indexPath.section][indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(productAmount.product.name)"
        cell.contentView.addSubview(nameLabel)
        
        let piecesLabel = productAmount.product.weightOfPiece != nil ? "| \((productAmount.amount / productAmount.product.weightOfPiece!).rounded(toPlaces: 2)) szt." : ""
        let detailsLabel = UILabelPadding(insets: TableViewComponent.defaultLabelPadding, labelText: "\(productAmount.amount) gr \(piecesLabel)")
        
        detailsLabel.layer.cornerRadius = 10.0
        detailsLabel.layer.borderWidth = 1.8
        detailsLabel.layer.borderColor = UIColor.systemBlue.cgColor
        cell.contentView.addSubview(detailsLabel)
        
        let productImageView = TableViewComponent.createImageView(photoInCell: productAmount.product.photo)
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
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addProductToShoppingListAction = UIContextualAction(style: .normal, title: Constants.editAmount) { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: Constants.confirm, message: Constants.addToShoppingListMessage, preferredStyle: .alert)
            confirmationAlert.addTextField { textField in
                textField.placeholder = Constants.enterAmount
                textField.keyboardType = .decimalPad
            }
            let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
            let addAction = UIAlertAction(title: Constants.add, style: .destructive) { (_) in
                if let amountText = confirmationAlert.textFields?.first?.text,
                   let amount = Double(amountText) {
                    self?.updateAmount(at: indexPath, amount: amount)
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
        
        let removeDishAction = UIContextualAction(style: .normal, title: Constants.removeProduct) { [weak self] (action, view, completionHandler) in
            self?.removeProductToBuy(at: indexPath)
            completionHandler(true)
        }
        removeDishAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func removeProductToBuy(at indexPath: IndexPath) {
        let productToRemove = selectedProductsGroupedByCategory[indexPath.section][indexPath.row]
        if let index = selectedProducts.firstIndex(where: { $0.product.id == productToRemove.product.id }) {
            selectedProducts.remove(at: index)
        }
        reloadProducts()
    }
    
    func updateAmount(at indexPath: IndexPath, amount: Double) {
        let productToUpdate = selectedProductsGroupedByCategory[indexPath.section][indexPath.row]
        productToUpdate.amount = amount
        if let index = selectedProducts.firstIndex(where: { $0.product.id == productToUpdate.product.id }) {
            selectedProducts[index] = productToUpdate
        }
        reloadProducts()
    }
}
