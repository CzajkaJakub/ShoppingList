import UIKit

import SQLite

class EatHistoryViewController: UIViewController {
        
    private let eatHistoryTable: UITableView = {
        let eatHistoryTable = UITableView()
        eatHistoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        eatHistoryTable.translatesAutoresizingMaskIntoConstraints = false
        return eatHistoryTable
    }()
    
    private var eatHistoryGroupedByCategory: [[EatHistory]] {
        let products = EatHistory.eatHistory.filter { $0.product != nil }
        let dishes = EatHistory.eatHistory.filter { $0.dish != nil }
        
        let groupedProducts = Dictionary(grouping: products) { $0.product!.category.name }
        let groupedDishes = Dictionary(grouping: dishes) { $0.dish!.category.name }
        
        let sortedProducts = groupedProducts.values.sorted(by: { $0[0].product!.category.name < $1[0].product!.category.name })
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
    
    private lazy var addToShoppingListButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDishesToShoppingList))
    }()
    
    private lazy var nextDayButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextDayAction))
    }()
    
    private lazy var previousDayButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(previousDayAction))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DateUtils.convertDateToMediumFormat(dateToConvert: self.searchDate)
        EatHistory.reloadEatItemsByDate(searchDate: self.searchDate)
        
        navigationItem.rightBarButtonItems = [self.nextDayButton, self.addToShoppingListButton]
        navigationItem.leftBarButtonItem = self.previousDayButton
        view.addSubview(eatHistoryTable)
        view.addSubview(eatValueLabel)
        
        eatHistoryTable.delegate = self
        eatHistoryTable.dataSource = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadView()
    }
    
    @objc private func addDishesToShoppingList() {
        let addHistoryItemsToShoppingList = UIAlertController(title: Constants.confirm, message: Constants.addToShoppingListMessage, preferredStyle: .alert)
        addHistoryItemsToShoppingList.addAction(UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil))
        addHistoryItemsToShoppingList.addAction(UIAlertAction(title: Constants.add, style: .destructive, handler: { _ in
            EatHistory.eatHistory.forEach{ historyItem in
                if historyItem.dish != nil {
                    ProductAmount.addProductToBuy(dish: historyItem.dish!)
                } else if historyItem.product != nil {
                    ProductAmount.addProductTuBuy(productAmount: ProductAmount(product: historyItem.product!, amount: historyItem.amount!))
                }
            }
        }))
        present(addHistoryItemsToShoppingList, animated: true, completion: nil)
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
        EatHistory.reloadEatItemsByDate(searchDate: self.searchDate)
        eatHistoryTable.reloadData()
        setupUI()
    }
    
    private func setupUI() {
        
        var totalCalories = 0.0
        var totalCarbo = 0.0
        var totalFat = 0.0
        var totalProteins = 0.0
        
        for item in EatHistory.eatHistory {
            if let product = item.product {
                totalCalories += product.calories * item.amount! / 100
                totalCarbo += product.carbo * item.amount! / 100
                totalFat += product.fat * item.amount! / 100
                totalProteins += product.protein * item.amount! / 100
            } else if let dish = item.dish {
                totalCalories += dish.calories * item.amount!
                totalCarbo += dish.carbo * item.amount!
                totalFat += dish.fat * item.amount!
                totalProteins += dish.proteins * item.amount!
            } else {
                Alert.displayErrorAlert(message: Constants.errorCalculation)
            }
        }
        
        totalCalories = totalCalories.rounded(toPlaces: 2)
        totalCarbo = totalCarbo.rounded(toPlaces: 2)
        totalFat = totalFat.rounded(toPlaces: 2)
        totalProteins = totalProteins.rounded(toPlaces: 2)
        
        eatValueLabel.text = "\(Constants.calories): \(totalCalories)  |  \(Constants.carbo): \(totalCarbo)\n\(Constants.fat): \(totalFat)  |  \(Constants.protein): \(totalProteins)"
        
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
        let categoryName = historyItem.dish != nil ? historyItem.dish!.category.name : historyItem.product!.category.name
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
        var archived: Bool!

        if let dish = eatItem.dish {
            name = dish.name
            photo = dish.photo
            calories = dish.calories * eatItem.amount!
            archived = dish.archived
        } else if let product = eatItem.product {
            name = product.name
            calories = product.calories * eatItem.amount! / 100
            photo = product.photo
            archived = false
        }
        
        var detailsText = ""
        if let calories = calories {
            detailsText = "\(Constants.calories): \(calories)"
        }
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        if (archived) {
            nameLabel.textColor = .red
        }
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
        
        let removeDishAction = UIContextualAction(style: .normal, title: Constants.remove) { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: Constants.confirm, message: Constants.removeRecipeMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: Constants.remove, style: .destructive) { (_) in
                self?.removeEatHistoryItem(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(removeAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true)
        }
        removeDishAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func removeEatHistoryItem(at indexPath: IndexPath) {
        let historyItem = eatHistoryGroupedByCategory[indexPath.section][indexPath.row]
        EatHistory.removeHistoryItem(historyItem: historyItem)
        reloadView()
    }
}



