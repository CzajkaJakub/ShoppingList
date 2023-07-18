//
//  DishesViewController.swift
//  ShoppingList
//
//  Created by Patrycja on 09/07/2023.
//

import UIKit

class DishesViewController: UIViewController {

    private var dishes: [Dish] = []
    private let dishesTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Dishes"
        view.addSubview(dishesTable)
        reloadDishes()
        
        dishesTable.delegate = self
        dishesTable.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dishesTable.frame = view.bounds
    }
    
    private func reloadDishes() {
        dishes = DatabaseManager.shared.fetchDishes()
        dishesTable.reloadData()
    }
}

extension DishesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dishesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let dish = dishes[indexPath.row]
        
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
        detailsLabel.text = "Kcal: \(dish.calories ?? 0) Carbs: \(dish.carbo ?? 0) Fat: \(dish.fat ?? 0) Protein \(dish.proteins ?? 0)"
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
        // Handle right swipe actions here
        let customAction = UIContextualAction(style: .normal, title: "Custom Action") { (action, view, completionHandler) in
            // Your custom code for the right swipe action
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        customAction.backgroundColor = .blue // Customize the action button background color

        let configuration = UISwipeActionsConfiguration(actions: [customAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Handle left swipe actions here
        let removeDishAction = UIContextualAction(style: .normal, title: "Remove dish") { [weak self] (action, view, completionHandler) in
            // Create a confirmation alert
            let confirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove this dish?", preferredStyle: .alert)
            
            // Add a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            confirmationAlert.addAction(cancelAction)
            
            // Add a remove action
            let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (_) in
                self?.removeDish(at: indexPath)
            }
            confirmationAlert.addAction(removeAction)
            
            // Present the confirmation alert
            self?.present(confirmationAlert, animated: true, completion: nil)
            
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        removeDishAction.backgroundColor = .red // Customize the action button background color

        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }

    func removeDish(at indexPath: IndexPath) {
        DatabaseManager.shared.removeDish(dish: dishes[indexPath.row])
        dishesTable.deleteRows(at: [indexPath], with: .left)
        dishes.remove(at: indexPath.row)
        reloadDishes()
    }
}
