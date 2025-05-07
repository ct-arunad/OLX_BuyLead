//
//  FilterTableViewController.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 04/04/25.
//

import Foundation
import UIKit

public protocol FilterPopupTableViewDelegate: AnyObject {
    func didSelectItemFromAll(_ item: String)
}

public class FilterTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public weak var delegate: FilterPopupTableViewDelegate?
    
    private let tableView = UITableView()
    public var items: [Any] = []
    public var topSectionData: [Any] = []
    public var bottomSectionData: [Any] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        setupTableView()
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
    public func configure(with items: [Any]) {
        self.items = items
        self.topSectionData = Array(items.prefix(self.items.count-2))
        self.bottomSectionData = Array(items.suffix(2))

    }
    private func setupTableView() {
        
        let centeredView = UIView()
        centeredView.backgroundColor = .white
        // Add the view to the parent view
        view.addSubview(centeredView)

        // Enable Auto Layout
        centeredView.translatesAutoresizingMaskIntoConstraints = false
        centeredView.layer.cornerRadius = 5

        // Center the view horizontally and vertically
        NSLayoutConstraint.activate([
            centeredView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centeredView.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-80), // Example width
            centeredView.heightAnchor.constraint(equalToConstant: 400) // Example height
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 30
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        centeredView.addSubview(tableView)
        tableView.isScrollEnabled = false

        NSLayoutConstraint.activate([
                  tableView.topAnchor.constraint(equalTo: centeredView.topAnchor, constant: 10),
                  tableView.leadingAnchor.constraint(equalTo: centeredView.leadingAnchor, constant: 0),
                  tableView.trailingAnchor.constraint(equalTo: centeredView.trailingAnchor, constant: 0),
                  tableView.bottomAnchor.constraint(equalTo: centeredView.bottomAnchor, constant: -10)
              ])
    }
    // MARK: - UITableView DataSource & Delegate
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        if(section == 0){
            headerView.backgroundColor = .white
            let imageview = UIImageView(frame: CGRect(x: 16, y: 0, width: 30, height: 30))
            imageview.layer.cornerRadius = imageview.frame.size.width / 2
            imageview.layer.masksToBounds = true
            imageview.image = UIImage(named: "filter", in: .framework, compatibleWith: nil)
            headerView.addSubview(imageview)
            let titleLabel = UILabel(frame: CGRect(x: 50, y: 0, width: tableView.frame.width, height: 30))
            titleLabel.text = "Filter"
            titleLabel.textColor = UIColor.OLXBlueColor
            titleLabel.font = .appFont(.medium, size: 20)
            headerView.addSubview(titleLabel)
        }
        else{
            headerView.backgroundColor = UIColor(red: 236/255, green: 241/255, blue: 255/255, alpha: 1.0)
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.width, height: 30))
            titleLabel.text = "Converted and Closed counts are not counted"
            titleLabel.textColor = UIColor.OLXBlueColor
            titleLabel.font = .appFont(.medium, size: 16)
            headerView.addSubview(titleLabel)
        }
        return headerView
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return topSectionData.count
        }
        return bottomSectionData.count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dic = indexPath.section == 0 ? topSectionData[indexPath.item] as! NSDictionary : bottomSectionData[indexPath.item] as! NSDictionary
        print((dic["name"] as! String))
        cell.textLabel?.text = "\((dic["name"] as! String)) (\((dic["count"] as! CVarArg)))"
        cell.textLabel?.font =  .appFont(.regular, size: 14)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = indexPath.section == 0 ? topSectionData[indexPath.item] as! NSDictionary : bottomSectionData[indexPath.item] as! NSDictionary
        delegate?.didSelectItemFromAll(dic["name"] as! String)
        dismiss(animated: true)
    }
}
