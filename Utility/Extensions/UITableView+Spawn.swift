

import UIKit

protocol FullScreenTableViewHolder: class {
    var separatorInset: UIEdgeInsets { get }
    func setupTableView(bottomAnchor: NSLayoutYAxisAnchor) -> UITableView
}

extension FullScreenTableViewHolder where Self: CommonVC & UITableViewDelegate & UITableViewDataSource {
    var separatorInset: UIEdgeInsets { return UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 0) }
    
    
    func setupTableView(bottomAnchor: NSLayoutYAxisAnchor) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.separatorInset = separatorInset
        
        if #available(iOS 11, *) {
            tableView.insetsContentViewsToSafeArea = true
        }
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topSafeAnchorIOS11(self)).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }
}
