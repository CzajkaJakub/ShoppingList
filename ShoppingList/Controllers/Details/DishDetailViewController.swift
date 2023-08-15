import UIKit

class DishDetailViewController: UIViewController {
    
    var dish: Dish!
    
    private lazy var eatDishButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(eatDishButtonTapped))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = dish.name
        setupUI()
    }
    
    @objc private func eatDishButtonTapped() {
        let eatItem = EatHistory(dateTime: Date.now, amount: nil, product: nil, dish: dish)
        EatHistory.addItemToEatHistory(eatItem: eatItem)
        Toast.showToast(message: "\(dish.name) was eaten!", parentView: self.view)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = eatDishButton
        
        let dishImageView = UIImageView()
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.layer.cornerRadius = 12
        dishImageView.clipsToBounds = true
        dishImageView.image = PhotoData.blobToUIImage(photoBlob: dish.photo)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        detailsLabel.textColor = .gray
        detailsLabel.numberOfLines = 0
        detailsLabel.text = """
            Kcal: \(dish.calories)  |  Carbs: \(dish.carbo)  |  Fat: \(dish.fat)  |  Protein: \(dish.proteins)
            """
        
        let productsList = UILabel()
        productsList.translatesAutoresizingMaskIntoConstraints = false
        productsList.font = UIFont.systemFont(ofSize: 14)
        productsList.textColor = .black
        productsList.numberOfLines = 0
        productsList.text = dish.productAmounts.map { productAmount in
            "\(productAmount.product.name) (\(productAmount.amount) grams)"
        }.joined(separator: "\n")
        
        let stackView = UIStackView(arrangedSubviews: [dishImageView, detailsLabel, productsList])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = TableViewComponent.stackViewAxis
        stackView.spacing = TableViewComponent.stackViewSpacing
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: TableViewComponent.detailsComponentMargin),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TableViewComponent.detailsComponentMargin),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TableViewComponent.detailsComponentMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -TableViewComponent.detailsComponentMargin),
            
            dishImageView.heightAnchor.constraint(equalTo: dishImageView.widthAnchor),
        ])
    }
}
