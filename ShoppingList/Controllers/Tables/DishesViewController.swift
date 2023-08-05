import UIKit

class DishesViewController: UIViewController {
    
    private let dishesTable: UITableView = {
        let dishesTable = UITableView()
        dishesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return dishesTable
    }()
    
    private var dishesGroupedByCategory: [[Dish]] {
        let groupedDishes = Dictionary(grouping: Dish.dishes, by: { $0.category.name })
        return groupedDishes.values.sorted(by: { $0[0].category.name < $1[0].category.name })
    }
    
    private lazy var addDishButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDishView))
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDishes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dishes"
        
        dishesTable.delegate = self
        dishesTable.dataSource = self
        
        navigationItem.rightBarButtonItem = addDishButton
        
        view.addSubview(dishesTable)
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
}

extension DishesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dishesGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishesGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: headerView.frame.height - 1, width: headerView.frame.width, height: 1)
        borderLayer.backgroundColor = UIColor.lightGray.cgColor
        headerView.layer.addSublayer(borderLayer)
        
        let mainLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 30))
        mainLabel.textColor = .systemBlue
        mainLabel.font = UIFont.boldSystemFont(ofSize: 18)
        mainLabel.text = dishesGroupedByCategory[section][0].category.name
        
        headerView.addSubview(mainLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dishesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let dish = dishesGroupedByCategory[indexPath.section][indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(dish.name)"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = .gray
        detailsLabel.text = "Calories: \(dish.calories) Carbs: \(dish.carbo) Fat: \(dish.fat) Protein \(dish.proteins)"
        cell.contentView.addSubview(detailsLabel)
        
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            
            detailsLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            detailsLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
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
        let selectedDish = dishesGroupedByCategory[indexPath.section][indexPath.row]
        let dishDetailViewController = DishDetailViewController()
        dishDetailViewController.dish = selectedDish
        navigationController?.pushViewController(dishDetailViewController, animated: true)
    }
    
    func removeDish(at indexPath: IndexPath) {
        let dish = dishesGroupedByCategory[indexPath.section][indexPath.row]
        Dish.removeDish(dish: dish)
        reloadDishes()
    }
    
    func addDishToShoppingList(at indexPath: IndexPath) {
        let dish = dishesGroupedByCategory[indexPath.section][indexPath.row]
        ProductAmount.addProductToBuy(dish: dish)
    }
}
