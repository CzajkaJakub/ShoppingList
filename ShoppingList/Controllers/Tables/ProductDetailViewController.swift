// ProductPopupViewController.swift

import UIKit

class ProductDetailViewController: UIViewController {
    
    var product: Product!
    
    private lazy var editProductButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProductButtonTapped))
    }()
    
    private lazy var eatButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(eatProductButtonTapped))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(product.name)"
        setupUI()
    }
    
    @objc private func editProductButtonTapped() {
        let editProductVC = AddProductViewController()
        editProductVC.editedProduct = product
        editProductVC.nameTextField.text = product.name
        editProductVC.carboTextField.text = String(product.carbo)
        editProductVC.kcalTextField.text = String(product.calories)
        editProductVC.fatTextField.text = String(product.fat)
        editProductVC.proteinTextField.text = String(product.protein)
        editProductVC.selectedPhoto = UIImage(data: Data(product.photo.bytes))
        editProductVC.reloadPhoto()
        navigationController?.pushViewController(editProductVC, animated: true)
    }
    
    @objc private func eatProductButtonTapped() {
        let amountAlert = UIAlertController(title: "Enter Amount", message: nil, preferredStyle: .alert)
        amountAlert.addTextField { textField in
            textField.placeholder = "Enter Amount (grams)"
            textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            
            let passedValueText = amountAlert.textFields?.first?.text!
            if let passedValue = StringUtils.convertTextFieldToDouble(stringValue: passedValueText!) {
                let eatItem = EatHistory(dateTime: Date.now, amount: passedValue, product: self!.product, dish: nil)
                EatHistory.addItemToEatHistory(eatItem: eatItem)
                Toast.shared.showToast(message: "\(self!.product.name) was eaten!", parentView: self!.view)
            } else {
                Toast.shared.showToast(message: "Wrong value text!", parentView: self!.view)
            }
        }
        
        amountAlert.addAction(cancelAction)
        amountAlert.addAction(addAction)
        self.present(amountAlert, animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        navigationItem.rightBarButtonItems = [editProductButton, eatButton]
        
        let productImageView = UIImageView()
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
        
        if let productPhoto = product?.photo {
            let photoData = Data.fromDatatypeValue(productPhoto)
            let photo = UIImage(data: photoData)
            productImageView.image = photo
            
            if let image = productImageView.image {
                // Calculate the aspect ratio to maintain the image's scale
                let aspectRatio = image.size.width / image.size.height
                // Calculate the height based on the width of the view and the aspect ratio
                let imageViewHeight = view.frame.width / aspectRatio
                // Set the height constraint of the productImageView
                productImageView.heightAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
            }
        }
        
        view.addSubview(productImageView)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.textColor = .gray
        detailsLabel.numberOfLines = 0
        detailsLabel.text = "Kcal: \(product.calories) Carbs: \(product.carbo) Fat: \(product.fat) Protein \(product.protein)"
        view.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            detailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
            
            productImageView.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 20),
            productImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            productImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            productImageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
        ])
    }
}
