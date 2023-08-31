import UIKit

import SQLite

class EatHistoryViewController: UIViewController {
        
    private let eatHistoryTable: UITableView = {
        let eatHistoryTable = UITableView()
        eatHistoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        eatHistoryTable.translatesAutoresizingMaskIntoConstraints = false
        return eatHistoryTable
    }()
    
    private var eatHistoryGroupedByCategory: [[EatHistoryItem]] {
        let products = EatHistoryItem.eatHistory.filter { $0.productAmount != nil }
        let dishes = EatHistoryItem.eatHistory.filter { $0.dish != nil }
        
        let groupedProducts = Dictionary(grouping: products) { $0.productAmount!.product.category.name }
        let groupedDishes = Dictionary(grouping: dishes) { $0.dish!.category.name }
        
        let sortedProducts = groupedProducts.values.sorted(by: { $0[0].productAmount!.product.category.name < $1[0].productAmount!.product.category.name })
        let sortedDishes = groupedDishes.values.sorted(by: { $0[0].dish!.category.name < $1[0].dish!.category.name })
        
        return sortedProducts + sortedDishes
    }
    
    private let eatValueLabel: UILabel = {
        let eatValues = UILabel()
        eatValues.translatesAutoresizingMaskIntoConstraints = false
        eatValues.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        eatValues.textColor = .gray
        eatValues.numberOfLines = 0
        return eatValues
    }()
    
    var searchDate: Date = Date()
    
    private lazy var nextDayButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextDayAction))
    }()
    
    private lazy var previousDayButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(previousDayAction))
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DateUtils.convertDateToMediumFormat(dateToConvert: self.searchDate)
        EatHistoryItem.reloadEatItemsByDate(searchDate: self.searchDate)
        
        navigationItem.rightBarButtonItem = self.nextDayButton
        navigationItem.leftBarButtonItem = self.previousDayButton
        view.addSubview(eatHistoryTable)
        view.addSubview(eatValueLabel)
        
        eatHistoryTable.delegate = self
        eatHistoryTable.dataSource = self
        setupUI()
    }
    
    @objc private func nextDayAction() {
        self.searchDate = Calendar.current.date(byAdding: .day, value: 1, to: self.searchDate)!
        reloadView()
    }
    
    @objc private func previousDayAction() {
        self.searchDate = Calendar.current.date(byAdding: .day, value: -1, to: self.searchDate)!
        reloadView()
    }
    
    private func reloadView() {
        self.title = DateUtils.convertDateToMediumFormat(dateToConvert: self.searchDate)
        EatHistoryItem.reloadEatItemsByDate(searchDate: self.searchDate)
        eatHistoryTable.reloadData()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        var totalCalories = 0.0
        var totalCarbo = 0.0
        var totalFat = 0.0
        var totalProteins = 0.0
        
        for item in EatHistoryItem.eatHistory {
            if let productAmount = item.productAmount {
                totalCalories += productAmount.product.calories * productAmount.amount / 100
                totalCarbo += productAmount.product.carbo * productAmount.amount / 100
                totalFat += productAmount.product.fat * productAmount.amount / 100
                totalProteins += productAmount.product.protein * productAmount.amount / 100
            } else if let dish = item.dish {
                totalCalories += dish.calories
                totalCarbo += dish.carbo
                totalFat += dish.fat
                totalProteins += dish.proteins
            } else {
                Toast.showToast(message: "Error powiedz Kubie", parentView: self.view)
            }
        }
        
        totalCalories = totalCalories.rounded(toPlaces: 2)
        totalCarbo = totalCarbo.rounded(toPlaces: 2)
        totalFat = totalFat.rounded(toPlaces: 2)
        totalProteins = totalProteins.rounded(toPlaces: 2)
        
        
        eatValueLabel.text = """
            Kcal: \(totalCalories)  |  Carbs: \(totalCarbo)\nFat: \(totalFat)  |  Protein: \(totalProteins)
            """
        
        NSLayoutConstraint.activate([
            eatValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eatValueLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            eatHistoryTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eatHistoryTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eatHistoryTable.topAnchor.constraint(equalTo: eatValueLabel.bottomAnchor),
            eatHistoryTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension EatHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return eatHistoryGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eatHistoryGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewComponent.tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let historyItem = eatHistoryGroupedByCategory[section][0]
        let categoryName = historyItem.dish != nil ? historyItem.dish!.category.name : historyItem.productAmount!.product.category.name
        return TableViewComponent.createHeaderForTable(tableView: tableView, headerName: categoryName)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewComponent.headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eatHistoryTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let eatItem = eatHistoryGroupedByCategory[indexPath.section][indexPath.row]
        
        var name: String!
        var calories: Double!
        var photo: Blob!

        if let dish = eatItem.dish {
            name = dish.name
            calories = dish.calories
            photo = dish.photo
        } else if let productAmount = eatItem.productAmount {
            name = productAmount.product.name
            calories = productAmount.product.calories * productAmount.amount / 100
            photo = productAmount.product.photo
        }
        
        var detailsText = ""
        if let calories = calories {
            detailsText = "Kcal: \(calories)"
        }
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = .gray
        detailsLabel.text = detailsText
        cell.contentView.addSubview(detailsLabel)
        
        let productImageView = TableViewComponent.createImageView(photoInCell: photo)
        cell.contentView.addSubview(productImageView)
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            
            detailsLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            detailsLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeDishAction = UIContextualAction(style: .normal, title: "Remove") { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove it?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (_) in
                self?.removeEatHistoryItem(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(removeAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true)
        }
        removeDishAction.backgroundColor = .red // Customize the action button background color
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }
    
    private func removeEatHistoryItem(at indexPath: IndexPath) {
        let historyItem = eatHistoryGroupedByCategory[indexPath.section][indexPath.row]
        EatHistoryItem.removeHistoryItem(historyItem: historyItem)
        reloadView()
    }
}



