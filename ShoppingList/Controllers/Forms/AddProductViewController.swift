//
//  AddProductViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class AddProductViewController: UIViewController {
    
    private var selectOptions: [Category] = []
    private var selectedOption: Category!
    private var selectedPhoto: UIImage!

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Product Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let photoTextField: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take Photo", for: .normal)
        button.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let kcalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Kcal"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private let carboTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Carbo"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private let fatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Fat"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private let proteinTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Protein"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveProduct), for: .touchUpInside)
        return button
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
        self.selectOptions = DatabaseManager.shared.fetchCategories()
        
        setupViews()
        setupConstraints()
        
        // Add the tap gesture recognizer to selectListTextField
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSelectList))
        selectListTextField.addGestureRecognizer(tapGesture)
        selectListTextField.isUserInteractionEnabled = true
    }
    
    private func setupViews() {
        view.addSubview(nameTextField)
        view.addSubview(photoTextField)
        view.addSubview(kcalTextField)
        view.addSubview(carboTextField)
        view.addSubview(fatTextField)
        view.addSubview(proteinTextField)
        view.addSubview(saveButton)
        view.addSubview(selectListTextField)
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 16
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            photoTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: margin),
            photoTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            photoTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            photoTextField.heightAnchor.constraint(equalToConstant: 40),
            
            kcalTextField.topAnchor.constraint(equalTo: photoTextField.bottomAnchor, constant: margin),
            kcalTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            kcalTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            kcalTextField.heightAnchor.constraint(equalToConstant: 40),
            
            carboTextField.topAnchor.constraint(equalTo: kcalTextField.bottomAnchor, constant: margin),
            carboTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            carboTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            carboTextField.heightAnchor.constraint(equalToConstant: 40),
            
            fatTextField.topAnchor.constraint(equalTo: carboTextField.bottomAnchor, constant: margin),
            fatTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            fatTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            fatTextField.heightAnchor.constraint(equalToConstant: 40),
            
            proteinTextField.topAnchor.constraint(equalTo: fatTextField.bottomAnchor, constant: margin),
            proteinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            proteinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            proteinTextField.heightAnchor.constraint(equalToConstant: 40),
            
            selectListTextField.topAnchor.constraint(equalTo: proteinTextField.bottomAnchor, constant: margin),
            selectListTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            selectListTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            selectListTextField.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: selectListTextField.bottomAnchor, constant: margin),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
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
        selectListActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        present(selectListActionSheet, animated: true, completion: nil)
    }
    
    @objc private func takePhoto() {
        // Implement the logic to capture a photo and save it to a variable
        // Here's a sample implementation using UIImagePickerController

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self // Make sure to conform to the UIImagePickerControllerDelegate
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Handle the case when the camera is not available
            print("Photo library is not available.")
        }
    }

    
    @objc private func saveProduct() {
        // Get the values from text fields
        guard let name = nameTextField.text,
              let photo = selectedPhoto,
              let kcalText = kcalTextField.text,
              let carboText = carboTextField.text,
              let fatText = fatTextField.text,
              let proteinText = proteinTextField.text,
              let kcal = Double(kcalText),
              let carbo = Double(carboText),
              let fat = Double(fatText),
              let protein = Double(proteinText)
        else {
            let message = "Invalid input"
            let font = UIFont.systemFont(ofSize: 16)
            let parentView = self.view
            Toast.shared.showToast(message: message, font: font, parentView: parentView!)
            return
        }
        
        // Create a product object with the entered values
        let product = Product(dbId: 0, name: name, photo: photo, kcal: kcal, carbo: carbo, fat: fat, protein: protein, category: Category(categoryId: selectedOption.categoryId, categoryName: selectedOption.categoryName))
        
        // Perform your desired action with the product object (e.g., save to a database)
        DatabaseManager.shared.insertProduct(product: product)
        
        // Show an alert or perform any other UI update to indicate successful save
        let alertController = UIAlertController(title: "Success", message: "Product saved successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
        // Clear the text fields after saving
        nameTextField.text = nil
        carboTextField.text = nil
        fatTextField.text = nil
        proteinTextField.text = nil
        kcalTextField
            .text = nil
        selectedPhoto = nil
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
        return selectOptions.count // Replace with your actual array of select options
    }
    
    // Example UIPickerViewDelegate method:
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Return the title for each row in the select list
        return selectOptions[row].categoryName // Replace with your actual array of select options
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle the selection of a row in the select list
        selectedOption = selectOptions[row] // Replace with your actual array of select options
        selectListTextField.text = selectedOption.categoryName
    }
}

// UIImagePickerControllerDelegate method to handle the captured photo
extension AddProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedPhoto = image
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
