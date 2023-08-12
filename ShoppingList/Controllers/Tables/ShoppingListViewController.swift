import UIKit

class ShoppingListViewController: UIViewController {
    
    private let productsTable: UITableView = {
        let productsTable = UITableView()
        productsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return productsTable
    }()
    
    private var productsToBuyGroupedByCategory: [[ProductAmount]] {
        let groupedProducts = Dictionary(grouping: ProductAmount.productsToBuy, by: { $0.product.category.name })
        return groupedProducts.values.sorted(by: { $0[0].product.category.name < $1[0].product.category.name })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadProducts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Shopping list"
        
        productsTable.delegate = self
        productsTable.dataSource = self
        
        view.addSubview(productsTable)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        productsTable.frame = view.bounds
    }
    
    @objc private func reloadProducts() {
        productsTable.reloadData()
    }
}

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return productsToBuyGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsToBuyGroupedByCategory[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
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
        mainLabel.text = productsToBuyGroupedByCategory[section][0].product.category.name
        
        headerView.addSubview(mainLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let productAmounts = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(productAmounts.product.name)"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabelPadding()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 13)
        detailsLabel.textColor = .black
        detailsLabel.text = "\(productAmounts.amount) gr"
        
        // Set up rounded border
        detailsLabel.layer.cornerRadius = 10.0 // Adjust the radius as needed for your design
        detailsLabel.layer.borderWidth = 1.3  // Width of the border
        detailsLabel.layer.borderColor = UIColor.gray.cgColor // Color of the border
        cell.contentView.addSubview(detailsLabel)
        
        let productImageView = UIImageView()
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 4
        productImageView.clipsToBounds = true
        
        let productPhoto = productAmounts.product.photo
        let photoData = Data.fromDatatypeValue(productPhoto)
        let photo = UIImage(data: photoData)
        productImageView.image = photo
        cell.contentView.addSubview(productImageView)
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            productImageView.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor, constant: -6),
            productImageView.widthAnchor.constraint(equalTo: productImageView.heightAnchor, multiplier: photo!.size.width / photo!.size.height),
  
            
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

            detailsLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            detailsLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeDishAction = UIContextualAction(style: .normal, title: "Remove product") { [weak self] (action, view, completionHandler) in
            self?.removeProductToBuy(at: indexPath)
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        removeDishAction.backgroundColor = .red // Customize the action button background color
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }
    
    func removeProductToBuy(at indexPath: IndexPath) {
        let productToRemove = productsToBuyGroupedByCategory[indexPath.section][indexPath.row]
        ProductAmount.removeProductToBuy(productToBuy: productToRemove)
        reloadProducts()
    }
}

