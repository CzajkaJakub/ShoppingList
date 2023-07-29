// ProductPopupViewController.swift

import UIKit

class ProductDetailViewController: UIViewController {

    var product: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16

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

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.text = product?.name
        view.addSubview(nameLabel)

        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.textColor = .gray
        detailsLabel.numberOfLines = 0
        detailsLabel.text = "Kcal: \(product?.calories ?? 0) Carbs: \(product?.carbo ?? 0) Fat: \(product?.fat ?? 0) Protein \(product?.protein ?? 0)"
        view.addSubview(detailsLabel)

         NSLayoutConstraint.activate([
             nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
             nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

             detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
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
