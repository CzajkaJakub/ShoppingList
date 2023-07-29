import UIKit

class DishesViewController: UIViewController {

    private let dishesTable: UITableView = {
        let dishesTable = UITableView()
        dishesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return dishesTable
    }()
    
    private var dishesGroupedByCategory: [[Dish]] {
        let groupedDishes = Dictionary(grouping: Dish.dishes, by: { $0.category.categoryName })
        return groupedDishes.values.sorted(by: { $0[0].category.categoryName < $1[0].category.categoryName })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDishes()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDishes()
        
        dishesTable.delegate = self
        dishesTable.dataSource = self
        
        view.addSubview(dishesTable)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dishesTable.frame = view.bounds
    }
    
    private func reloadDishes() {
        dishesTable.reloadData()
    }
}

extension DishesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return dishesGroupedByCategory.count
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return dishesGroupedByCategory[section].count
     }

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return dishesGroupedByCategory[section][0].category.categoryName
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dishesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let dish = dishesGroupedByCategory[indexPath.section][indexPath.row]

        let dishImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFit
                imageView.layer.cornerRadius = 16
                imageView.clipsToBounds = true
            if let productPhoto = dish.photo {
                    let photoData = Data.fromDatatypeValue(productPhoto)
                    let photo = UIImage(data: photoData)
                    imageView.image = photo
                }
                return imageView
            }()
        cell.contentView.addSubview(dishImageView)
        
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
                dishImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                dishImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                dishImageView.widthAnchor.constraint(equalToConstant: 32),
                dishImageView.heightAnchor.constraint(equalToConstant: 32),
                
                nameLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 10),
                nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                
                detailsLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 10),
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

    func removeDish(at indexPath: IndexPath) {
        let dish = dishesGroupedByCategory[indexPath.section][indexPath.row]
        DatabaseManager.shared.removeDish(dish: dish)
        Dish.removeDish(dish: dish)
        reloadDishes()
    }
    
    func addDishToShoppingList(at indexPath: IndexPath) {
        let dish = dishesGroupedByCategory[indexPath.section][indexPath.row]
        ProductAmount.addProductToBuy(dish: dish)
        DatabaseManager.shared.addDishToShoppingList(dish: dish)
    }
}
