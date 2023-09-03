import Foundation
import UIKit

class ProductSelectionViewController: UIViewController {
    
    private var allProductsGroupedByCategory: [[Product]] {
        let groupedProducts = Dictionary(grouping: Product.products, by: { $0.category.name })
        return groupedProducts.values.sorted(by: { $0[0].category.name < $1[0].category.name })
    }
    
    private var filteredProductsGroupedByCategory: [[Product]] = []
    
    private lazy var searchButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchAlert))
    }()
    
    private lazy var clearSearchButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clearSearchTerm))
    }()
    
    private weak var productsTable: UITableView!
    weak var delegate: ProductSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Product"
        setupTableView()
    }
    
    private func setupTableView() {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "productCell")
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItems = [clearSearchButton, searchButton]
        view.addSubview(tableView)
        self.productsTable = tableView
        self.clearSearchTerm()
    }
    
    @objc private func clearSearchTerm() {
        self.filterProducts(searchTerm: nil)
    }
    
    @objc func showSearchAlert() {
        let alertController = UIAlertController(title: "Search", message: "Enter a search term", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Search term"
        }

        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            if let searchTerm = alertController.textFields?.first?.text {
                self?.filterProducts(searchTerm: searchTerm)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func filterProducts(searchTerm: String?) {
        if searchTerm == nil || searchTerm!.isEmpty {
            filteredProductsGroupedByCategory = allProductsGroupedByCategory
        } else {
            filteredProductsGroupedByCategory = allProductsGroupedByCategory.map { products in
                products.filter { product in
                    let productName = product.name.lowercased()
                    return productName.contains(searchTerm!.lowercased())
                }
            }.filter { !$0.isEmpty }
        }
        productsTable.reloadData()
    }
}

extension ProductSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredProductsGroupedByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProductsGroupedByCategory[section].count
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
        mainLabel.text = filteredProductsGroupedByCategory[section][0].category.name
        
        headerView.addSubview(mainLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        cell.textLabel?.text = "\(product.name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = filteredProductsGroupedByCategory[indexPath.section][indexPath.row]
        
        let amountAlert = UIAlertController(title: "Enter Amount", message: nil, preferredStyle: .alert)
        amountAlert.addTextField { textField in
            textField.placeholder = "Enter Amount (grams)"
            textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            
            let passedValueText = amountAlert.textFields?.first?.text!
            if let passedValue = StringUtils.convertTextFieldToDouble(stringValue: passedValueText!) {
                self?.delegate?.didSelectProduct(product, amount: passedValue)
                Toast.showToast(message: "\(product.name) (\(passedValue) grams) added!", parentView: self!.view)
            } else {
                Toast.showToast(message: "Wrong value text!", parentView: self!.view)
            }
        }
        
        amountAlert.addAction(cancelAction)
        amountAlert.addAction(addAction)
        self.present(amountAlert, animated: true, completion: nil)
    }
}
