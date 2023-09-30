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
    
    private var selectedDate: Date = Date()
    private var filteredDishesGroupedByCategory: [[Dish]] = []
    private var isFavouriteDishesButtonSelected = false
    private var searchTerm = ""
    
    private lazy var favouriteButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.addTarget(self, action: #selector(starButtonTapped), for: .touchUpInside)
                
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }()
    
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
        self.title = Constants.dishes
        
        dishesTable.delegate = self
        dishesTable.dataSource = self
        
        navigationItem.rightBarButtonItems = [addDishButton, searchButton]
        navigationItem.leftBarButtonItems = [favouriteButton, clearSearchButton]
        
        view.addSubview(dishesTable)
        
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
        self.searchTerm = ""
        self.filterDishes()
    }
    
    private func openDishViewController(editMode: Bool, dish: Dish){
        let editDishVC = AddDishViewController()
        
        if editMode == true {
            editDishVC.editedDish = dish
        }
                
        editDishVC.nameTextField.text = dish.name
        editDishVC.dishDescriptionTextField.text = dish.description
        editDishVC.selectedProducts = dish.productAmounts.map { $0.copy() as! ProductAmount }
        editDishVC.selectedPhoto = PhotoData.blobToUIImage(photoBlob: dish.photo)
        editDishVC.selectedOption = dish.category
        editDishVC.amountOfPortionTextField.text = dish.amountOfPortion != nil ? String(dish.amountOfPortion!) : nil
        editDishVC.reloadPhoto()
        navigationController?.pushViewController(editDishVC, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
    }
    
    @objc func editDishAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: dishesTable)
            
            if let indexPath = dishesTable.indexPathForRow(at: point) {
                let dish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
                
                let alertController = UIAlertController(title: Constants.chooseAction, message: nil, preferredStyle: .actionSheet)
                
                let editAction = UIAlertAction(title: Constants.edit, style: .default) { (_) in
                    self.openDishViewController(editMode: true, dish: dish)
                }
                
                var favouriteButton: UIAlertAction! = nil
                if (!dish.favourite) {
                    favouriteButton = UIAlertAction(title: Constants.addToFavourite, style: .default) { (_) in
                        dish.favourite = true
                        Dish.updateDish(dish: dish)
                        self.reloadDishes()
                    }
                } else {
                    favouriteButton = UIAlertAction(title: Constants.removeFromFavourite, style: .default) { (_) in
                        dish.favourite = false
                        Dish.updateDish(dish: dish)
                        self.reloadDishes()
                    }
                }
                
                
                let addNewAction = UIAlertAction(title: Constants.copy, style: .default) { (_) in
                    self.openDishViewController(editMode: false, dish: dish)
                }
                
                let eatDishAction = UIAlertAction(title: Constants.eatDish, style: .default) { (_) in
                    
                    let amountAlert = UIAlertController(title: "\(Constants.enterDate)\n", message: nil, preferredStyle: .alert)
                    
                    amountAlert.addTextField { textField in
                        textField.placeholder = Constants.enterAmountDishAmount
                        textField.keyboardType = .decimalPad
                    }
                    
                    let datePicker: UIDatePicker = {
                        let datePicker = UIDatePicker()
                        datePicker.datePickerMode = .date
                        datePicker.date = Date()
                        datePicker.translatesAutoresizingMaskIntoConstraints = false
                        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
                        return datePicker
                    }()
                    
                    amountAlert.view.addSubview(datePicker)
                    
                    datePicker.topAnchor.constraint(equalTo: amountAlert.view.topAnchor, constant: 42).isActive = true
                    datePicker.centerXAnchor.constraint(equalTo: amountAlert.view.centerXAnchor).isActive = true
                    
                    let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
                    let addAction = UIAlertAction(title: Constants.add, style: .default) { [weak self] _ in
                        
                        let passedValueText = amountAlert.textFields?.first?.text!
                        if let passedValue = StringUtils.convertTextFieldToDouble(stringValue: passedValueText!) {
                            
                            let eatItem = EatHistoryItem(dish: dish, product: nil, amount: passedValue, eatDate: self!.selectedDate)
                            EatHistoryItem.addItemToEatHistory(eatItem: eatItem)
                            
                        } else {
                            Toast.showToast(message: Constants.enteredWrongDoubleValueMessage, parentView: self!.view)
                        }
                    }
                    
                    amountAlert.addAction(cancelAction)
                    amountAlert.addAction(addAction)
                    self.present(amountAlert, animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(favouriteButton)
                alertController.addAction(eatDishAction)
                alertController.addAction(editAction)
                alertController.addAction(addNewAction)
                alertController.addAction(cancelAction)
            
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func filterDishes() {
        if searchTerm.isEmpty {
            filteredDishesGroupedByCategory = allDishesGroupedByCategory
        } else {
            filteredDishesGroupedByCategory = allDishesGroupedByCategory.map { dishes in
                dishes.filter { dish in
                    let dishName = dish.name.lowercased()
                    return dishName.contains(searchTerm.lowercased())
                }
            }.filter { !$0.isEmpty }
        }
        
        if isFavouriteDishesButtonSelected {
            filteredDishesGroupedByCategory = filteredDishesGroupedByCategory.map { dishes in
                dishes.filter { dish in
                    return dish.favourite
                }
            }.filter { !$0.isEmpty }
        }
        
        self.reloadDishes()
    }
    
    @objc private func starButtonTapped() {
        isFavouriteDishesButtonSelected.toggle()
        
        let favouriteStarImage = isFavouriteDishesButtonSelected ? "star.fill" : "star"
        if let button = favouriteButton.customView as? UIButton {
            button.setImage(UIImage(systemName: favouriteStarImage), for: .normal)
        }
        
        self.filterDishes()
    }
        
    
    
    @objc func showSearchAlert() {
        let alertController = UIAlertController(title: Constants.search, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = Constants.searchTerm
        }

        let searchAction = UIAlertAction(title: Constants.search, style: .default) { [weak self] _ in
            if let searchTerm = alertController.textFields?.first?.text {
                self?.searchTerm = searchTerm
                self?.filterDishes()
            }
        }

        let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)

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
        nameLabel.numberOfLines = 0
        nameLabel.text = "\(dish.name)"
        
        if (dish.favourite) {
            nameLabel.textColor = UIColor(named: Constants.favouriteDishLabelColor)
        }
        
        cell.contentView.addSubview(nameLabel)
        
        
        let dishImageView = TableViewComponent.createImageView(photoInCell: dish.photo)
        cell.contentView.addSubview(dishImageView)
        
        NSLayoutConstraint.activate([
            dishImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            dishImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
            nameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addDishToShoppingListAction = UIContextualAction(style: .normal, title: Constants.shoppingList) { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: Constants.confirm, message: Constants.addToShoppingListMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
            let addAction = UIAlertAction(title: Constants.add, style: .destructive) { (_) in
                self?.addDishToShoppingList(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(addAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true)
        }
        addDishToShoppingListAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [addDishToShoppingListAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let archiveDish = UIContextualAction(style: .normal, title: Constants.archive) { [weak self] (action, view, completionHandler) in
            let confirmationAlert = UIAlertController(title: Constants.confirm, message: Constants.archiveMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil)
            let removeAction = UIAlertAction(title: Constants.archive, style: .destructive) { (_) in
                self?.archiveDish(at: indexPath)
            }
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(removeAction)
            self?.present(confirmationAlert, animated: true, completion: nil)
            completionHandler(true)
        }
        
        archiveDish.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [archiveDish])
        configuration.performsFirstActionWithFullSwipe = false
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
    
    func archiveDish(at indexPath: IndexPath) {
        let dish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
        Dish.archiveDish(dish: dish)
        self.filterDishes()
    }
    
    func addDishToShoppingList(at indexPath: IndexPath) {
        let dish = filteredDishesGroupedByCategory[indexPath.section][indexPath.row]
        ProductAmount.addProductToBuy(dish: dish)
    }
}
