//
//  DropdownView.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 09/04/25.
//

import Foundation
import UIKit

class DropdownView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var items: [String] = []
    var onItemSelected: ((String) -> Void)?
    var headerTitle = ""
    
    private let tableView = UITableView()
    
    init(items: [String],headertitle : String, frame: CGRect) {
        super.init(frame: frame)
        self.items = items
        self.headerTitle = headertitle
        setupTable()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupTable() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 8
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        addSubview(tableView)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.0/255.0, green: 71.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 50))
        titleLabel.text = self.headerTitle
        titleLabel.textColor = .white
        titleLabel.font = .appFont(.medium, size: 12)
        headerView.addSubview(titleLabel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clearData))
        headerView.addGestureRecognizer(tapGesture)
        headerView.isUserInteractionEnabled = true
        return headerView
    }
    @objc func clearData()
    {
        onItemSelected?(self.headerTitle)
        removeFromSuperview()
    }
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 0.0/255.0, green: 71.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        cell.textLabel?.font = .appFont(.medium, size: 12)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onItemSelected?(items[indexPath.row])
        removeFromSuperview()
    }
}
