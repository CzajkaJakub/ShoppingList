// ProductPopupViewController.swift

import UIKit

class DishDetailViewController: UIViewController {

    var dish: Dish!
    
    private lazy var editDishButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDishButtonTapped))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(dish.name)"
        setupUI()
    }
    
    @objc private func editDishButtonTapped() {
        let editDishVC = AddDishViewController()
        editDishVC.editedDish = dish
        editDishVC.selectedProducts = dish.productAmounts
        editDishVC.nameTextField.text = dish.name
        editDishVC.selectedPhoto = UIImage(data: Data(dish.photo.bytes))
        editDishVC.reloadPhoto()
        navigationController?.pushViewController(editDishVC, animated: true)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        navigationItem.rightBarButtonItems = [editDishButton]
        
        let dishImageView = UIImageView()
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        dishImageView.contentMode = .scaleAspectFit
        dishImageView.layer.cornerRadius = 8
        dishImageView.clipsToBounds = true
        
        if let dishPhoto = dish?.photo {
            let photoData = Data.fromDatatypeValue(dishPhoto)
            let photo = UIImage(data: photoData)
            dishImageView.image = photo
            
            if let image = dishImageView.image {
                // Calculate the aspect ratio to maintain the image's scale
                let aspectRatio = image.size.width / image.size.height
                // Calculate the height based on the width of the view and the aspect ratio
                let imageViewHeight = view.frame.width / aspectRatio
                // Set the height constraint of the productImageView
                dishImageView.heightAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
            }
        }
        
        view.addSubview(dishImageView)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.textColor = .gray
        detailsLabel.numberOfLines = 0
        detailsLabel.text = "Kcal: \(dish.calories) Carbs: \(dish.carbo) Fat: \(dish.fat) Protein \(dish.proteins)"
        view.addSubview(detailsLabel)
        
        let productsList = UILabel()
        productsList.translatesAutoresizingMaskIntoConstraints = false
        productsList.font = UIFont.systemFont(ofSize: 14)
        productsList.textColor = .black
        productsList.numberOfLines = 0
        productsList.text = dish.productAmounts.map { productAmount in
            "\(productAmount.product.name) (\(productAmount.amount) grams)"
        }.joined(separator: "\n")
        
        view.addSubview(productsList)
        
        NSLayoutConstraint.activate([
            productsList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            productsList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            productsList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            productsList.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
            
            detailsLabel.topAnchor.constraint(equalTo: productsList.bottomAnchor, constant: 20),
            detailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
            
            dishImageView.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 20),
            dishImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dishImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dishImageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
        ])
    }
}
