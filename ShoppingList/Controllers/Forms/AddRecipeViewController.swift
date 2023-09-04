import UIKit

class AddRecipeViewController: UIViewController {
    
    private var imageViewHeightConstraint: NSLayoutConstraint?
    internal var selectedPhoto: UIImage!
    internal var selectedDate: Date = Date()
    
    internal let recipeImageView: UIImageView = {
        let productImageView = UIImageView()
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFill
        productImageView.layer.cornerRadius = 12
        productImageView.clipsToBounds = true
        return productImageView
    }()
    
    internal let recipeValueTextField: UITextField = {
        let recipeValueTextField = UITextField()
        recipeValueTextField.placeholder = "Value"
        recipeValueTextField.borderStyle = .roundedRect
        recipeValueTextField.translatesAutoresizingMaskIntoConstraints = false
        recipeValueTextField.keyboardType = .decimalPad
        return recipeValueTextField
    }()
    
    internal let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(saveRecipe))
    }()
    
    private lazy var clearButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearFields))
    }()
    
    private lazy var selectPhotoButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectPhoto))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        navigationItem.rightBarButtonItems = [selectPhotoButton, clearButton, saveButton]
        
        setupConstraints()
        
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureKeyboard)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
    }
    
    private func setupConstraints() {
        
        let stackView = UIStackView(arrangedSubviews: [datePicker, recipeValueTextField, recipeImageView])
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
    
    
    @objc private func saveRecipe() {
        
        guard let photo = selectedPhoto,
              let recipeValue = StringUtils.convertTextFieldToDouble(stringValue: recipeValueTextField.text!)
        else {
            Toast.showToast(message: "Invalid input", parentView: self.view)
            return
        }
        
        Recipe.addRecipe(recipe: Recipe(date: selectedDate, amount: recipeValue, photo: photo))
        
        // Show an alert or perform any other UI update to indicate successful save
        let alertController = UIAlertController(title: "Success", message: "Recipe saved successfully.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.recipeImageView.image = nil
            self.imageViewHeightConstraint?.isActive = false
            self.recipeValueTextField.text = nil
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func clearFields() {
        let alertController = UIAlertController(title: "Clear Fields", message: "Are you sure you want to clear the recipe?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            self.recipeImageView.image = nil
            self.imageViewHeightConstraint?.isActive = false
            self.recipeValueTextField.text = nil
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func reloadPhoto(){
        recipeImageView.image = selectedPhoto
        
        if let image = recipeImageView.image {
            let maxAllowedHeight = UIScreen.main.bounds.height * 0.35
            let aspectRatio = image.size.width / image.size.height
            let imageViewHeight = min(view.frame.width / aspectRatio, maxAllowedHeight)
            
            imageViewHeightConstraint = recipeImageView.heightAnchor.constraint(equalToConstant: imageViewHeight)
            imageViewHeightConstraint?.isActive = true
        }
    }
}


// UIImagePickerControllerDelegate method to handle the captured photo
extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
