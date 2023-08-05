import UIKit

class AddProductViewController: UIViewController {
    
    private var imageViewHeightConstraint: NSLayoutConstraint?
    internal var selectOptions: [Category] = []
    internal var selectedOption: Category!
    internal var selectedPhoto: UIImage!
    internal var editedProduct: Product!
    
    internal let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Product Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    internal let productImageView: UIImageView = {
        let productImageView = UIImageView()
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
        return productImageView
    }()
    
    internal let kcalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Kcal / 100g"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    internal let carboTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Carbo / 100g"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    internal let fatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Fat / 100g"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    internal let proteinTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Protein / 100g"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(saveProduct))
    }()
    
    private lazy var clearButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearFields))
    }()
    
    private lazy var selectPhotoButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectPhoto))
    }()
    
    private let selectListTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select an category"
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        self.selectedOption = self.editedProduct == nil ? Category.productCategories.first : self.editedProduct.category
        self.selectListTextField.text = selectedOption.name
        
        navigationItem.rightBarButtonItems = [selectPhotoButton, clearButton, saveButton]
        
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
        view.addSubview(kcalTextField)
        view.addSubview(carboTextField)
        view.addSubview(fatTextField)
        view.addSubview(proteinTextField)
        view.addSubview(productImageView)
        view.addSubview(selectListTextField)
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 16
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            productImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            productImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            productImageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            
            nameTextField.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: margin),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            kcalTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: margin),
            kcalTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            kcalTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            kcalTextField.heightAnchor.constraint(equalToConstant: 40),
            
            proteinTextField.topAnchor.constraint(equalTo: kcalTextField.bottomAnchor, constant: margin),
            proteinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            proteinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            proteinTextField.heightAnchor.constraint(equalToConstant: 40),
            
            fatTextField.topAnchor.constraint(equalTo: proteinTextField.bottomAnchor, constant: margin),
            fatTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            fatTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            fatTextField.heightAnchor.constraint(equalToConstant: 40),
            
            carboTextField.topAnchor.constraint(equalTo: fatTextField.bottomAnchor, constant: margin),
            carboTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            carboTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            carboTextField.heightAnchor.constraint(equalToConstant: 40),
            
            selectListTextField.topAnchor.constraint(equalTo: carboTextField.bottomAnchor, constant: margin),
            selectListTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            selectListTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            selectListTextField.heightAnchor.constraint(equalToConstant: 40),
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
        selectListActionSheet.addAction(UIAlertAction(title: "Chose", style: .cancel, handler: nil))
        
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
    
    
    @objc private func saveProduct() {
        
        guard let name = nameTextField.text,
              let photo = selectedPhoto,
              let kcal = StringUtils.convertTextFieldToDouble(stringValue: kcalTextField.text!),
              let carbo = StringUtils.convertTextFieldToDouble(stringValue: carboTextField.text!),
              let fat = StringUtils.convertTextFieldToDouble(stringValue: fatTextField.text!),
              let protein = StringUtils.convertTextFieldToDouble(stringValue: proteinTextField.text!)
        else {
            Toast.shared.showToast(message: "Invalid input", parentView: self.view)
            return
        }
        
        if editedProduct != nil {
            let productToUpdate = Product(id: editedProduct.id!, name: name, photo: photo, kcal: kcal, carbo: carbo, fat: fat, protein: protein, category: Category(id: selectedOption.id!, name: selectedOption.name))
            Product.updateProduct(product: productToUpdate)
        } else {
            let productToSave = Product(name: name, photo: photo, kcal: kcal, carbo: carbo, fat: fat, protein: protein, category: Category(id: selectedOption.id!, name: selectedOption.name))
            Product.addProduct(product: productToSave)
        }
        
        // Show an alert or perform any other UI update to indicate successful save
        let alertController = UIAlertController(title: "Success", message: "Product saved successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        clearFields()
    }
    
    @objc private func clearFields() {
        let alertController = UIAlertController(title: "Clear Fields", message: "Are you sure you want to clear the product?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            self.productImageView.image = nil
            self.imageViewHeightConstraint?.isActive = false
            self.nameTextField.text = nil
            self.carboTextField.text = nil
            self.fatTextField.text = nil
            self.proteinTextField.text = nil
            self.kcalTextField
                .text = nil
            self.selectedPhoto = nil
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func reloadPhoto(){
        productImageView.image = selectedPhoto
        
        if let image = productImageView.image {
            let maxAllowedHeight = UIScreen.main.bounds.height * 0.35
            let aspectRatio = image.size.width / image.size.height
            let imageViewHeight = min(view.frame.width / aspectRatio, maxAllowedHeight)
            
            imageViewHeightConstraint = productImageView.heightAnchor.constraint(equalToConstant: imageViewHeight)
            imageViewHeightConstraint?.isActive = true
        }
    }
}

extension AddProductViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // Implement the required methods for UIPickerViewDataSource and UIPickerViewDelegate here
    
    // Example UIPickerViewDataSource methods:
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Return the number of components (columns) in the select list
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Return the number of rows in the select list
        return Category.productCategories.count // Replace with your actual array of select options
    }
    
    // Example UIPickerViewDelegate method:
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Return the title for each row in the select list
        return Category.productCategories[row].name // Replace with your actual array of select options
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle the selection of a row in the select list
        selectedOption = Category.productCategories[row] // Replace with your actual array of select options
        selectListTextField.text = selectedOption.name
    }
}

// UIImagePickerControllerDelegate method to handle the captured photo
extension AddProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
