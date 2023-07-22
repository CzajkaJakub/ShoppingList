//  AddDishViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class AddDishViewController: UIViewController, UIPickerViewDelegate {

    private var selectedPhoto: UIImage!
    private var selectedProducts: [ProductAmount] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(nameTextField)
        view.addSubview(photoTextField)
        view.addSubview(saveButton)
        view.addSubview(addProductButton)
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
            
            saveButton.topAnchor.constraint(equalTo: photoTextField.bottomAnchor, constant: margin),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            addProductButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: margin),
            addProductButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            addProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            addProductButton.heightAnchor.constraint(equalToConstant: 44),
            ])
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
              let photo = selectedPhoto
        else {
            let message = "Invalid input"
            let font = UIFont.systemFont(ofSize: 16)
            let parentView = self.view
            Toast.shared.showToast(message: message, font: font, parentView: parentView!)
            return
        }
        
        // Create a dish object with the entered values and selected products
        let dish = Dish(id: 0,name: name, photo: selectedPhoto, calories: selectedProducts.map {$0.product.kcal * $0.amount / 100}.reduce(0, +),carbo: selectedProducts.map {$0.product.carbo * $0.amount / 100}.reduce(0, +), fat: selectedProducts.map {$0.product.fat * $0.amount / 100}.reduce(0, +), protein: selectedProducts.map {$0.product.protein * $0.amount / 100}.reduce(0, +), productAmounts: selectedProducts)
        
        // Perform your desired action with the dish object (e.g., save to a database)
         DatabaseManager.shared.insertDish(dish: dish) // Implement the DatabaseManager method for inserting dishes
        
        // Show an alert or perform any other UI update to indicate successful save
        let alertController = UIAlertController(title: "Success", message: "Dish saved successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
        // Clear the text fields and selected products after saving
        nameTextField.text = nil
        selectedPhoto = nil
        selectedProducts.removeAll()
    }
    
    @objc private func addProductButtonTapped() {
        let productSelectionVC = ProductSelectionViewController()
        productSelectionVC.delegate = self
        navigationController?.pushViewController(productSelectionVC, animated: true)
    }
}

// UIImagePickerControllerDelegate method to handle the captured photo
extension AddDishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    private var products: [Product] = []
    private weak var tableView: UITableView!
    weak var delegate: ProductSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Product"
        
        products = DatabaseManager.shared.fetchProducts()
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = "\(product.name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        
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

