import UIKit

class DishesViewController: UIViewController {
    
    private let dishesTable: UITableView = {
        let dishesTable = UITableView()
        dishesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return dishesTable
    }()
    
    private var allDishesGroupedByCategory: [[Dish]] {
        let groupedDishes = Dictionary(grouping: Dish.dishes, by: { $0.category.name })
        return groupedDishes.values.sorted(by: { $0[0].category.name < $1[0].category.name })
    }
    
    private var filteredDishesGroupedByCategory: [[Dish]] = []
    
    private lazy var addDishButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDishView))
    }()
    
    private lazy var searchButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchAlert))
    }()
    
    private lazy var clearSearchButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clearSearchTerm))
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearSearchTerm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dishes"
        
        dishesTable.delegate = self
        dishesTable.dataSource = self
        
        navigationItem.rightBarButtonItems = [addDishButton, searchButton]
        navigationItem.leftBarButtonItems = [clearSearchButton]
        
        view.addSubview(dishesTable)
        
        // Add a long-press gesture recognizer to the table view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(editDishAction(_:)))
        dishesTable.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dishesTable.frame = view.bounds
    }
    
    private func reloadDishes() {
        dishesTable.reloadData()
    }
    
    @objc private func addDishView() {
        navigationController?.pushViewController(AddDishViewController(), animated: true)
    }
    
    @objc private func clearSearchTerm() {
        self.filterDishes(searchTerm: nil)
    }
    
    private func openDishViewController(editMode: Bool, dish: Dish){
        let editDishVC = AddDishViewController()
        
        if editMode == true {
            editDishVC.editedDish = dish
        }
        
        editDishVC.selectedProducts = dish.productAmounts
        editDishVC.nameTextField.text = dish.name
        editDishVC.selectedPhoto = PhotoData.blobToUIImage(photoBlob: dish.photo)
        editDishVC.selectedOption = dish.category
        editDishVC.reloadPhoto()
        navigationController?.pushViewController(editDishVC, animated: true)
    }
    
    @objc func editDishAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: dishesTable)
            
            if let indexPath = dishesTable.indexPathForRow(at: point) {
                let dish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
                
                let alertController = UIAlertController(title: "Options", message: "Choose an action:", preferredStyle: .actionSheet)
                
                let editAction = UIAlertAction(title: "Edit", style: .default) { (_) in
                    self.openDishViewController(editMode: true, dish: dish)
                }
                
                let addNewAction = UIAlertAction(title: "Copy", style: .default) { (_) in
                    self.openDishViewController(editMode: false, dish: dish)
                }
                
                let eatDishAction = UIAlertAction(title: "Eat dish", style: .default) { (_) in
                    let eatItem = EatHistoryItem(dish: dish)
                    EatHistoryItem.addItemToEatHistory(eatItem: eatItem)
                    Toast.showToast(message: "\(dish.name) was eaten!", parentView: self.view)
                }
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(eatDishAction)
                alertController.addAction(editAction)
                alertController.addAction(addNewAction)
                alertController.addAction(cancelAction)
            
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func filterDishes(searchTerm: String?) {
        if searchTerm == nil || searchTerm!.isEmpty {
            filteredDishesGroupedByCategory = allDishesGroupedByCategory
        } else {
            filteredDishesGroupedByCategory = allDishesGroupedByCategory.map { dishes in
                dishes.filter { dish in
                    let dishName = dish.name.lowercased()
                    return dishName.contains(searchTerm!.lowercased())
                }
            }.filter { !$0.isEmpty }
        }
        dishesTable.reloadData()
    }
    
    @objc func showSearchAlert() {
        let alertController = UIAlertController(title: "Search", message: "Enter a search term", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Search term"
        }

        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            if let searchTerm = alertController.textFields?.first?.text {
                self?.filterDishes(searchTerm: searchTerm)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension DishesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredDishesGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDishesGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewComponent.tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewComponent.createHeaderForTable(tableView: tableView, headerName: filteredDishesGroupedByCategory[section][0].category.name)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewComponent.headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dishesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let dish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(dish.name)"
        cell.contentView.addSubview(nameLabel)
        
        let dishImageView = TableViewComponent.createImageView(photoInCell: dish.photo)
        cell.contentView.addSubview(dishImageView)
        
        NSLayoutConstraint.activate([
            dishImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            dishImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addDishToShoppingListAction = UIContextualAction(style: .normal, title: "Add meal to shopping list") { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to add this dish to list?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let addAction = UIAlertAction(title: "Add", style: .destructive) { (_) in
                self?.addDishToShoppingList(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(addAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        addDishToShoppingListAction.backgroundColor = .blue // Customize the action button background color
        
        let configuration = UISwipeActionsConfiguration(actions: [addDishToShoppingListAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeDishAction = UIContextualAction(style: .normal, title: "Remove dish") { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove this dish?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (_) in
                self?.removeDish(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(removeAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        removeDishAction.backgroundColor = .red // Customize the action button background color
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDishDetail(for: indexPath)
    }
    
    private func showDishDetail(for indexPath: IndexPath) {
        let selectedDish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
        let dishDetailViewController = DishDetailViewController()
        dishDetailViewController.dish = selectedDish
        navigationController?.pushViewController(dishDetailViewController, animated: true)
    }
    
    func removeDish(at indexPath: IndexPath) {
        let dish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
        Dish.removeDish(dish: dish)
        reloadDishes()
    }
    
    func addDishToShoppingList(at indexPath: IndexPath) {
        let dish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
        ProductAmount.addProductToBuy(dish: dish)
    }
}
