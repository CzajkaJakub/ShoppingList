import UIKit

import SQLite

class RecipesViewController: UIViewController {
    
    private lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        return recognizer
    }()
        
    private let recipesTable: UITableView = {
        let eatHistoryTable = UITableView()
        eatHistoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        eatHistoryTable.translatesAutoresizingMaskIntoConstraints = false
        return eatHistoryTable
    }()
    
    private let recipeLabel: UILabel = {
        let recipeLabel = UILabel()
        recipeLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        recipeLabel.textColor = .gray
        recipeLabel.numberOfLines = 0
        return recipeLabel
    }()
    
    var searchMonth: Date = Date()
    
    private lazy var nextMonthButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextMonthAction))
    }()
    
    private lazy var previousMonthButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(previousManthAction))
    }()
    
    private lazy var addRecipeButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeView))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DateUtils.convertDateToMediumFormat(dateToConvert: self.searchMonth)
        self.recipesTable.addGestureRecognizer(longPressRecognizer)
        EatHistoryItem.reloadEatItemsByDate(searchDate: self.searchMonth)
        
        navigationItem.rightBarButtonItems = [self.nextMonthButton, addRecipeButton]
        navigationItem.leftBarButtonItem = self.previousMonthButton
        view.addSubview(recipesTable)
        view.addSubview(recipeLabel)
        
        recipesTable.delegate = self
        recipesTable.dataSource = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadView()
    }
    
    @objc private func nextMonthAction() {
        self.searchMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.searchMonth)!
        reloadView()
    }
    
    @objc private func previousManthAction() {
        self.searchMonth = Calendar.current.date(byAdding: .month, value: -1, to: self.searchMonth)!
        reloadView()
    }
    
    @objc private func addRecipeView() {
        navigationController?.pushViewController(AddRecipeViewController(), animated: true)
    }
    
    private func reloadView() {
        self.title = DateUtils.convertRangeToShortFormat(monthToConvert: self.searchMonth)
        Recipe.reloadEatItemsByDate(searchDateFrom: searchMonth.startOfMonth, searchDateTo: searchMonth.endOfMonth)
        recipesTable.reloadData()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        recipeLabel.text = "Sum : \(Recipe.recipes.map {$0.amount}.reduce(0, +).rounded(toPlaces: 2))"
        
        NSLayoutConstraint.activate([
            recipeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recipeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            recipesTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recipesTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recipesTable.topAnchor.constraint(equalTo: recipeLabel.bottomAnchor),
            recipesTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.recipesTable)
            if let indexPath = self.recipesTable.indexPathForRow(at: touchPoint) {
                let recipe = Recipe.recipes[indexPath.row]

                let popupVC = PopUpModalViewController()
                popupVC.blobImageToDisplay = recipe.photo

                popupVC.modalPresentationStyle = .overFullScreen
                popupVC.modalTransitionStyle = .crossDissolve
                self.present(popupVC, animated: true)
            }
        }
    }
}

extension RecipesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Recipe.recipes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewComponent.tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewComponent.createHeaderForTable(tableView: tableView, headerName: "Recipes")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewComponent.headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let recipe = Recipe.recipes[indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "\(recipe.amount.rounded(toPlaces: 2)) zl"
        cell.contentView.addSubview(nameLabel)
        
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 12)
        detailsLabel.textColor = .gray
        detailsLabel.text = "\(DateUtils.convertDateToMediumFormat(dateToConvert: recipe.dateTime))"
        cell.contentView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            
            detailsLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            detailsLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let removeDishAction = UIContextualAction(style: .normal, title: "Remove recipe") { [weak self] (action, view, completionHandler) in
            self?.removeRecipe(at: indexPath)
            completionHandler(true) // Call the completion handler to indicate that the action was performed
        }
        removeDishAction.backgroundColor = .red // Customize the action button background color
        
        let configuration = UISwipeActionsConfiguration(actions: [removeDishAction])
        configuration.performsFirstActionWithFullSwipe = false // Allow partial swipe to trigger the action
        return configuration
    }
    
    func removeRecipe(at indexPath: IndexPath) {
        let recipeToRemove = Recipe.recipes[indexPath.row]
        Recipe.removeRecipe(recipe: recipeToRemove)
        reloadView()
    }
}
