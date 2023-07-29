//  AddDishViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class AddDishViewController: UIViewController {

    private var selectedPhoto: UIImage!
    private var selectedProducts: [ProductAmount] = []
    private var selectedOption: Category!
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Dish Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let photoTextField: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Dish", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveDish), for: .touchUpInside)
        return button
    }()
    
    private let addProductButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Product", for: .normal)
        button.addTarget(self, action: #selector(addProductButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        self.selectedOption = Category.dishCategories.first
        self.selectListTextField.text = selectedOption.categoryName
        
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
        view.addSubview(photoTextField)
        view.addSubview(saveButton)
        view.addSubview(addProductButton)
        view.addSubview(selectListTextField)
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 16
        let photoTextFieldMaxWidth = view.bounds.width * 0.5
        
        NSLayoutConstraint.activate([
            photoTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            photoTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoTextField.widthAnchor.constraint(lessThanOrEqualToConstant: photoTextFieldMaxWidth),
            photoTextField.heightAnchor.constraint(equalToConstant: 64),
            
            nameTextField.topAnchor.constraint(equalTo: photoTextField.bottomAnchor, constant: margin),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            addProductButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: margin),
            addProductButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            addProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            addProductButton.heightAnchor.constraint(equalToConstant: 44),
            
            selectListTextField.topAnchor.constraint(equalTo: addProductButton.bottomAnchor, constant: margin),
            selectListTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            selectListTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            selectListTextField.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: selectListTextField.bottomAnchor, constant: margin),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
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
    
  
    @objc private func takePhoto() {
        // Implement the logic to capture a photo and save it to a variable
        // Here's a sample implementation using UIImagePickerController

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Photo library is not available.")
        }
    }

    @objc private func saveDish() {
        // Get the values from text fields
        guard let name = nameTextField.text,
              let photo = selectedPhoto,
              let category = selectedOption
        else {
            let message = "Invalid input"
            let font = UIFont.systemFont(ofSize: 16)
            let parentView = self.view
            Toast.shared.showToast(message: message, font: font, parentView: parentView!)
            return
        }
        
        // Create a dish object with the entered values and selected products
        let dish = Dish(id: 0,name: name, photo: photo, calories: selectedProducts.map {$0.product.calories * $0.amount / 100}.reduce(0, +), carbo: selectedProducts.map {$0.product.carbo * $0.amount / 100}.reduce(0, +), fat: selectedProducts.map {$0.product.fat * $0.amount / 100}.reduce(0, +), protein: selectedProducts.map {$0.product.protein * $0.amount / 100}.reduce(0, +), productAmounts: selectedProducts, category: category)
        
        // Perform your desired action with the dish object (e.g., save to a database)
        DatabaseManager.shared.insertDish(dish: dish) // Implement the DatabaseManager method for inserting dishes
        Dish.dishes.append(dish)
        
        // Show an alert or perform any other UI update to indicate successful save
        let alertController = UIAlertController(title: "Success", message: "Dish saved successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
        // Clear the text fields and selected products after saving
        photoTextField.setTitle("Take photo", for: .normal)
        photoTextField.setBackgroundImage(nil, for: .normal)
        nameTextField.text = nil
        selectedPhoto = nil
        selectedProducts.removeAll()
    }
    
    @objc private func addProductButtonTapped() {
        let productSelectionVC = ProductSelectionViewController()
        productSelectionVC.delegate = self
        navigationController?.pushViewController(productSelectionVC, animated: true)
    }
    
    @objc func dismissKeyboard() {
         view.endEditing(true)
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
        return Category.dishCategories[row].categoryName // Replace with your actual array of select options
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle the selection of a row in the select list
        selectedOption = Category.dishCategories[row] // Replace with your actual array of select options
        selectListTextField.text = selectedOption.categoryName
    }
}


// UIImagePickerControllerDelegate method to handle the captured photo
extension AddDishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedPhoto = image
            // Set the selected photo as the background image of the photoTextField
            photoTextField.setTitle(nil, for: .normal)
            photoTextField.setBackgroundImage(image, for: .normal)
            
            // Calculate the adjusted width and height based on the photo's aspect ratio
            let photoAspectRatio = image.size.width / image.size.height
            let photoTextFieldMaxWidth = view.bounds.width * 0.5
            let photoTextFieldHeight = min(photoTextFieldMaxWidth / photoAspectRatio, photoTextFieldMaxWidth)
            let photoTextFieldWidth = min(photoTextFieldMaxWidth, photoTextFieldMaxWidth * photoAspectRatio)
            photoTextField.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = photoTextFieldHeight
                } else if constraint.firstAttribute == .width {
                    constraint.constant = photoTextFieldWidth
                }
            }
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
        navigationController?.popViewController(animated: true)
    }
}

protocol ProductSelectionDelegate: AnyObject {
    func didSelectProduct(_ product: Product, amount: Double)
}

class ProductSelectionViewController: UIViewController {
    private weak var tableView: UITableView!
    weak var delegate: ProductSelectionDelegate?
    
    private var productsGroupedByCategory: [[Product]] {
        let groupedProducts = Dictionary(grouping: Product.products, by: { $0.category.categoryName })
        return groupedProducts.values.sorted(by: { $0[0].category.categoryName < $1[0].category.categoryName })
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

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return productsGroupedByCategory[section][0].category.categoryName
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
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

        // Present an alert to enter the amount of the selected product
        let amountAlert = UIAlertController(title: "Enter Amount", message: nil, preferredStyle: .alert)
        amountAlert.addTextField { textField in
            textField.placeholder = "Enter Amount"
            textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let amountText = amountAlert.textFields?.first?.text,
               let amount = Double(amountText) {
                self?.delegate?.didSelectProduct(product, amount: amount)
            }
        }
        
        amountAlert.addAction(cancelAction)
        amountAlert.addAction(addAction)
        present(amountAlert, animated: true, completion: nil)
    }
}

