import UIKit

class AddProductViewController: UIViewController {
    
    private var imageViewHeightConstraint: NSLayoutConstraint?
    internal var selectOptions: [Category] = []
    internal var selectedOption: Category!
    internal var selectedPhoto: UIImage!
    internal var editedProduct: Product!
    
    internal let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.productName
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    internal let productImageView: UIImageView = {
        let productImageView = UIImageView()
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFill
        productImageView.layer.cornerRadius = 12
        productImageView.clipsToBounds = true
        return productImageView
    }()
    
    internal let kcalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.caloriesPer100Grams
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    internal let carboTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.carboPer100Grams
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    internal let fatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.fatPer100Grams
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    internal let proteinTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.proteinPer100Grams
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    internal let weightOfPieceTextField: UITextField = {
        let weightOfPieceTextField = UITextField()
        weightOfPieceTextField.placeholder = Constants.weightOfPiece
        weightOfPieceTextField.borderStyle = .roundedRect
        weightOfPieceTextField.translatesAutoresizingMaskIntoConstraints = false
        weightOfPieceTextField.keyboardType = .decimalPad
        return weightOfPieceTextField
    }()
    
    internal let weightOfProductTextField: UITextField = {
        let weightOfPieceTextField = UITextField()
        weightOfPieceTextField.placeholder = Constants.weightOfProduct
        weightOfPieceTextField.borderStyle = .roundedRect
        weightOfPieceTextField.translatesAutoresizingMaskIntoConstraints = false
        weightOfPieceTextField.keyboardType = .decimalPad
        return weightOfPieceTextField
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
        textField.placeholder = Constants.selectCategory
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 16
        
        if self.selectedOption == nil { self.selectedOption = Category.productCategories.first }
        self.selectListTextField.text = selectedOption.name
        
        navigationItem.rightBarButtonItems = [selectPhotoButton, clearButton, saveButton]
        
        setupConstraints()
        
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureKeyboard)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSelectList))
        selectListTextField.addGestureRecognizer(tapGesture)
        selectListTextField.isUserInteractionEnabled = true
    }
    
    private func setupConstraints() {
        
        let stackView = UIStackView(arrangedSubviews: [productImageView, nameTextField, kcalTextField, proteinTextField, fatTextField, carboTextField, weightOfPieceTextField, weightOfProductTextField, selectListTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = TableViewComponent.stackViewAxis
        stackView.spacing = TableViewComponent.stackViewSpacing
        
        view.addSubview(stackView)
            
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: TableViewComponent.detailsComponentMargin),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TableViewComponent.detailsComponentMargin),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TableViewComponent.detailsComponentMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -TableViewComponent.detailsComponentMargin)
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
    
    
    @objc private func saveProduct() {
        
        guard let name = nameTextField.text,
              let photo = selectedPhoto,
              let kcal = StringUtils.convertTextFieldToDouble(stringValue: kcalTextField.text!),
              let carbo = StringUtils.convertTextFieldToDouble(stringValue: carboTextField.text!),
              let fat = StringUtils.convertTextFieldToDouble(stringValue: fatTextField.text!),
              let protein = StringUtils.convertTextFieldToDouble(stringValue: proteinTextField.text!)
        else {
            Toast.showToast(message: Constants.fillEmptyFields, parentView: self.view)
            return
        }
        
        let weightOfPiece = weightOfPieceTextField.text != nil ? StringUtils.convertTextFieldToDouble(stringValue: weightOfPieceTextField.text!) : nil
        let weightOfProduct = weightOfProductTextField.text != nil ? StringUtils.convertTextFieldToDouble(stringValue: weightOfProductTextField.text!) : nil
        
        if editedProduct != nil {
            let photoBlob = try! PhotoData.convertUIImageToResizedBlob(imageToResize: selectedPhoto)
            let productToUpdate = Product(id: editedProduct.id!, name: name, photo: photoBlob, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, weightOfProduct: weightOfProduct, category: Category(id: selectedOption.id!, name: selectedOption.name))
            Product.updateProduct(product: productToUpdate)
        } else {
            let productToSave = Product(name: name, photo: photo, kcal: kcal, carbo: carbo, fat: fat, protein: protein, weightOfPiece: weightOfPiece, weightOfProduct: weightOfProduct, category: Category(id: selectedOption.id!, name: selectedOption.name))
            Product.addProduct(product: productToSave)
        }
        
        let alertController = UIAlertController(title: Constants.success, message: Constants.productWasSaved, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.ok, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        clearFields()
    }
    
    @objc private func clearFields() {
        let alertController = UIAlertController(title: Constants.clearFields, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: Constants.clear, style: .destructive, handler: { _ in
            self.productImageView.image = nil
            self.imageViewHeightConstraint?.isActive = false
            self.nameTextField.text = nil
            self.carboTextField.text = nil
            self.fatTextField.text = nil
            self.proteinTextField.text = nil
            self.kcalTextField
                .text = nil
            self.selectedPhoto = nil
            self.weightOfPieceTextField.text = nil
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.productCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.productCategories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = Category.productCategories[row]
        selectListTextField.text = selectedOption.name
    }
}

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
