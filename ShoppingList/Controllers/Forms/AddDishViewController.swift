import UIKit

class AddDishViewController: UIViewController, UITableViewDelegate {
    
    private var imageViewHeightConstraint: NSLayoutConstraint?
    internal var selectedPhoto: UIImage!
    internal var selectedProducts: [ProductAmount] = []
    internal var selectedOption: Category!
    internal var editedDish: Dish!
    
    internal let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Dish Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let dishImageView: UIImageView = {
        let dishImageView = UIImageView()
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        dishImageView.contentMode = .scaleAspectFit
        dishImageView.layer.cornerRadius = 8
        dishImageView.clipsToBounds = true
        return dishImageView
    }()
    
    
    private let selectListTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select an category"
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
    
    private lazy var showProductsButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProductsButtonTapped))
    }()
    
    private lazy var selectPhotoButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectPhoto))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        self.selectedOption = self.editedDish == nil ? Category.dishCategories.first : self.editedDish.category
        self.selectListTextField.text = selectedOption.name
        
        navigationItem.rightBarButtonItems = [selectPhotoButton, clearButton, addProductButton, showProductsButton, saveButton]
        
        setupViews()
        setupConstraints()
        
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureKeyboard)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSelectList))
        selectListTextField.addGestureRecognizer(tapGesture)
        selectListTextField.isUserInteractionEnabled = true
    }
    
    private func setupViews() {
        view.addSubview(nameTextField)
        view.addSubview(dishImageView)
        view.addSubview(selectListTextField)
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 16
        
        NSLayoutConstraint.activate([
            selectListTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            selectListTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            selectListTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            selectListTextField.heightAnchor.constraint(equalToConstant: 40),
            
            nameTextField.topAnchor.constraint(equalTo: selectListTextField.bottomAnchor, constant: margin),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            dishImageView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            dishImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dishImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dishImageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
        ])
    }
    
    @objc private func showSelectList() {
        let selectList = UIPickerView()
        selectList.delegate = self // Conform to the UIPickerViewDelegate protocol
        selectList.dataSource = self // Conform to the UIPickerViewDataSource protocol
        
        // Create an action sheet to contain the select list
        let selectListActionSheet = UIAlertController(title: "Select an option", message: nil, preferredStyle: .actionSheet)
        selectListActionSheet.view.addSubview(selectList)
        
        // Define the constraints for the select list within the action sheet
        selectList.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectList.leadingAnchor.constraint(equalTo: selectListActionSheet.view.leadingAnchor),
            selectList.trailingAnchor.constraint(equalTo: selectListActionSheet.view.trailingAnchor),
            selectList.topAnchor.constraint(equalTo: selectListActionSheet.view.topAnchor),
            selectList.bottomAnchor.constraint(equalTo: selectListActionSheet.view.bottomAnchor, constant: -44) // Adjust the constant as needed
        ])
        
        // Add a "Cancel" button to dismiss the action sheet
        selectListActionSheet.addAction(UIAlertAction(title: "Choose", style: .cancel, handler: nil))
        
        // Present the action sheet
        present(selectListActionSheet, animated: true, completion: nil)
    }
    
    
    @objc private func selectPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let imageSourceAlert = UIAlertController(title: "Select source of photo", message: nil, preferredStyle: .alert)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let librarySourceButton = UIAlertAction(title: "Library", style: .default) { [weak self] _ in
                imagePicker.sourceType = .photoLibrary
                self?.present(imagePicker, animated: true, completion: nil)
            }
            imageSourceAlert.addAction(librarySourceButton)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraSourceButton = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                imagePicker.sourceType = .camera
                self?.present(imagePicker, animated: true, completion: nil)
            }
            imageSourceAlert.addAction(cameraSourceButton)
        }
        
        if imageSourceAlert.actions.isEmpty {
            print("Photo library and camera are not available.")
            return
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        imageSourceAlert.addAction(cancelAction)
        
        self.present(imageSourceAlert, animated: true, completion: nil)
    }
    
    @objc private func saveDish() {
        
        guard let name = nameTextField.text,
              let photo = selectedPhoto,
              let category = selectedOption
        else {
            Toast.shared.showToast(message: "Invalid input", parentView: self.view)
            return
        }
        
        if editedDish != nil {
            let dishToUpdate = Dish(id: editedDish.id!, name: name, photo: photo, productAmounts: selectedProducts, category: category)
            Dish.updateDish(dish: dishToUpdate)
        } else {
            let dishToSave = Dish(name: name, photo: photo, productAmounts: selectedProducts, category: category)
            Dish.addDish(dish: dishToSave)
        }
        
        // Show an alert or perform any other UI update to indicate successful save
        let alertController = UIAlertController(title: "Success", message: "Dish saved successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        clearFields()
    }
    
    @objc private func clearFields() {
        let alertController = UIAlertController(title: "Clear Fields", message: "Are you sure you want to clear the dish?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
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
    
    @objc private func editProductsButtonTapped() {
        let productSelectionVC = ProductListViewController()
        productSelectionVC.delegate = self
        productSelectionVC.selectedProducts = selectedProducts
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
}

extension AddDishViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // Implement the required methods for UIPickerViewDataSource and UIPickerViewDelegate here
    
    // Example UIPickerViewDataSource methods:
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Return the number of components (columns) in the select list
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Return the number of rows in the select list
        return Category.dishCategories.count // Replace with your actual array of select options
    }
    
    // Example UIPickerViewDelegate method:
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Return the title for each row in the select list
        return Category.dishCategories[row].name // Replace with your actual array of select options
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle the selection of a row in the select list
        selectedOption = Category.dishCategories[row] // Replace with your actual array of select options
        selectListTextField.text = selectedOption.name
    }
}


// UIImagePickerControllerDelegate method to handle the captured photo
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


extension AddDishViewController: ProductSelectionDelegate, ProductListDelegate {
    func didSelectProduct(_ product: Product, amount: Double) {
        selectedProducts.append(ProductAmount(product: product, amount: amount))
    }
    
    func removeProductFromDishList(productIndex: Int) {
        selectedProducts.remove(at: productIndex)
    }
}

protocol ProductSelectionDelegate: AnyObject {
    func didSelectProduct(_ product: Product, amount: Double)
}

class ProductSelectionViewController: UIViewController {
    private weak var tableView: UITableView!
    weak var delegate: ProductSelectionDelegate?
    
    private var productsGroupedByCategory: [[Product]] {
        let groupedProducts = Dictionary(grouping: Product.products, by: { $0.category.name })
        return groupedProducts.values.sorted(by: { $0[0].category.name < $1[0].category.name })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Product"
        setupTableView()
    }
    
    private func setupTableView() {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "productCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        self.tableView = tableView
    }
}

extension ProductSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return productsGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: headerView.frame.height - 1, width: headerView.frame.width, height: 1)
        borderLayer.backgroundColor = UIColor.lightGray.cgColor
        headerView.layer.addSublayer(borderLayer)
        
        let mainLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 30))
        mainLabel.textColor = .systemBlue
        mainLabel.font = UIFont.boldSystemFont(ofSize: 18)
        mainLabel.text = productsGroupedByCategory[section][0].category.name
        
        headerView.addSubview(mainLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let product = productsGroupedByCategory[indexPath.section][indexPath.row]
        cell.textLabel?.text = "\(product.name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = productsGroupedByCategory[indexPath.section][indexPath.row]
        
        let amountAlert = UIAlertController(title: "Enter Amount", message: nil, preferredStyle: .alert)
        amountAlert.addTextField { textField in
            textField.placeholder = "Enter Amount (grams)"
            textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            
            let passedValueText = amountAlert.textFields?.first?.text!
            if let passedValue = StringUtils.convertTextFieldToDouble(stringValue: passedValueText!) {
                self?.delegate?.didSelectProduct(product, amount: passedValue)
                Toast.shared.showToast(message: "\(product.name) (\(passedValue) grams) added!", parentView: self!.view)
            } else {
                Toast.shared.showToast(message: "Wrong value text!", parentView: self!.view)
            }
        }
        
        amountAlert.addAction(cancelAction)
        amountAlert.addAction(addAction)
        self.present(amountAlert, animated: true, completion: nil)
    }
}

protocol ProductListDelegate: AnyObject {
    func removeProductFromDishList(productIndex: Int)
}

class ProductListViewController: UIViewController {
    private weak var tableView: UITableView!
    weak var delegate: ProductListDelegate?
    fileprivate var selectedProducts: [ProductAmount] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Product"
        setupTableView()
    }
    
    private func setupTableView() {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "productCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        self.tableView = tableView
    }
}


extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedProducts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: headerView.frame.height - 1, width: headerView.frame.width, height: 1)
        borderLayer.backgroundColor = UIColor.lightGray.cgColor
        headerView.layer.addSublayer(borderLayer)
        
        let mainLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 30))
        mainLabel.textColor = .systemBlue
        mainLabel.font = UIFont.boldSystemFont(ofSize: 18)
        mainLabel.text = "Product list"
        
        headerView.addSubview(mainLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let product = selectedProducts[indexPath.row]
        cell.textLabel?.text = "\(product.product.name) \(product.amount)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeProductFromDishAction = UIContextualAction(style: .normal, title: "Remove product") { [weak self] (action, view, completionHandler) in
            self?.delegate?.removeProductFromDishList(productIndex: indexPath.row)
            self?.selectedProducts.remove(at: indexPath.row)
            tableView.reloadData()
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        removeProductFromDishAction.backgroundColor = UIColor.red
        
        let configuration = UISwipeActionsConfiguration(actions: [removeProductFromDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }
}

