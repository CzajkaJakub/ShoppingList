import UIKit

class EatHistoryViewController: UIViewController {
    
//    private let eatHistoryTable: UITableView = {
//        let eatHistoryTable = UITableView()
//        eatHistoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        return eatHistoryTable
//    }()
//
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        realoadEatHistoryTable()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "Eat history"
//
////        eatHistoryTable.delegate = self
////        eatHistoryTable.dataSource = self
//
//        view.addSubview(eatHistoryTable)
//
//    }
//
//    private func realoadEatHistoryTable() {
//        eatHistoryTable.reloadData()
//    }
}

//extension EatHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return EatHistory.eatHistory.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 64
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = eatHistoryTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
//        let eatHistoryItem = EatHistory.eatHistory[indexPath.row]
//
//        let nameLabel = UILabel()
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        nameLabel.text = "\(eatHistoryItem.id)"
//        cell.contentView.addSubview(nameLabel)
//
//        let detailsLabel = UILabel()
//        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
//        detailsLabel.font = UIFont.systemFont(ofSize: 12)
//        detailsLabel.textColor = .gray
//        detailsLabel.text = "\(eatHistoryItem.dateTime)"
//        cell.contentView.addSubview(detailsLabel)
//
//        NSLayoutConstraint.activate([
//            nameLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
//            nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
//
//            detailsLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
//            detailsLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
//        ])
//
//        return cell
//    }
//}


