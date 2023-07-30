// ProductPopupViewController.swift

import UIKit

class DishDetailViewController: UIViewController {

    var dish: Dish!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(dish.name)"
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
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
        
        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
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
