import UIKit

class EatHistoryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calories dictionary"
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        var totalCalories = 0.0
        var totalCarbo = 0.0
        var totalFat = 0.0
        var totalProteins = 0.0
        
        let eatItemsList = UILabel()
        eatItemsList.translatesAutoresizingMaskIntoConstraints = false
        eatItemsList.font = UIFont.systemFont(ofSize: 14)
        eatItemsList.textColor = .black
        eatItemsList.numberOfLines = 0
        eatItemsList.text = ""
        
        for item in EatHistoryItem.eatHistory {
            if let productAmount = item.productAmount {
                totalCalories += productAmount.product.calories * productAmount.amount / 100
                totalCarbo += productAmount.product.carbo * productAmount.amount / 100
                totalFat += productAmount.product.fat * productAmount.amount / 100
                totalProteins += productAmount.product.protein * productAmount.amount / 100
                eatItemsList.text?.append("\(productAmount.product.name) (\(productAmount.amount) grams)\n")
            } else if let dish = item.dish {
                totalCalories += dish.calories
                totalCarbo += dish.carbo
                totalFat += dish.fat
                totalProteins += dish.proteins
                eatItemsList.text?.append("\(dish.name)\n")
            } else {
                Toast.showToast(message: "Error powiedz Kubie", parentView: self.view)
            }
        }
        
        let eatValues = UILabel()
        eatValues.translatesAutoresizingMaskIntoConstraints = false
        eatValues.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        eatValues.textColor = .gray
        eatValues.numberOfLines = 0
        eatValues.text = """
            Kcal: \(totalCalories)  |  Carbs: \(totalCarbo)  |  Fat: \(totalFat)  |  Protein: \(totalProteins)
            """
        
        let stackView = UIStackView(arrangedSubviews: [eatValues, eatItemsList])
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
}

