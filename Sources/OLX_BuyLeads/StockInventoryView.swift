//
//  StockInventoryView.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 11/04/25.
//

import Foundation
import UIKit
public protocol StockTableViewDelegate: AnyObject {
    func didSelectStock(_ name: String,addID : String)
}
public class StockInventoryView : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    public weak var delegate: StockTableViewDelegate?
    let searchBar = UISearchBar()

    private let tableView = UITableView()
    public var items: [Ads] = []
    public var searchAds : [Ads] = []
    var issearchtoggle = false

    public override func viewDidLoad() {
        self.view.backgroundColor = .white
        super.viewDidLoad()
        self.items = self.getStockList()
        self.setupTableView()
     //   loadInventory()
    }
    public func getStockList()->[Ads]{
        return InventoryAPIManager.sharedInstance.getStocks() as! [Ads]
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
   
    private func setupTableView() {
        
        tableView.backgroundColor = .cellbg
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorColor = .none
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self

    }
    // MARK: - UITableView DataSource & Delegate
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let imageview = UIImageView(frame: CGRect(x: 16, y: 10, width: 30, height: 30))
        imageview.layer.cornerRadius = imageview.frame.size.width / 2
        imageview.backgroundColor = .sendsms
        imageview.layer.masksToBounds = true
        imageview.image = UIImage.named("filter")
        headerView.addSubview(imageview)
        let titleLabel = UILabel(frame: CGRect(x: 50, y: 10, width: tableView.frame.width, height: 30))
        titleLabel.text = "Inventory Cars"
        titleLabel.textColor = UIColor.OLXBlueColor
        titleLabel.font = .appFont(.medium, size: 14)
        headerView.addSubview(titleLabel)
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: tableView.frame.width - 50, y: 10, width: 25, height: 25)
        let image = UIImage(named: "close", in: .framework, compatibleWith: nil)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.isUserInteractionEnabled = true
        headerView.addSubview(button)
        
        searchBar.delegate = self
        searchBar.placeholder = "Search for Inventory Car"
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(searchBar)

               // Layout constraints
        NSLayoutConstraint.activate([
        searchBar.topAnchor.constraint(equalTo: button.safeAreaLayoutGuide.bottomAnchor,constant: 20),
        searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
        searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
        return headerView
    }
    // MARK: - UISearchBarDelegate
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
     public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         self.issearchtoggle = true
        print("Searching: \(searchText)")
         let filteredUsers = items.filter {
             $0.name!.localizedCaseInsensitiveContains(searchText)
         }
         if(searchText.count == 0){
             self.searchAds = self.items
         }
         else{
             self.searchAds = filteredUsers
         }
         self.tableView.reloadData()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.issearchtoggle = false
        self.items = self.getStockList()
        self.tableView.reloadData()

    }
   @objc func dismissView()
    {
        self.dismiss(animated: false, completion: nil)
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(issearchtoggle){
            return searchAds.count
        }
        return items.count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(issearchtoggle){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let Adstock = searchAds[indexPath.row]
            let name = Adstock.name ?? ""
            cell.textLabel?.text = "\(items[indexPath.row].adId!) \(name)"
            cell.textLabel?.font =  .appFont(.regular, size: 14)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let Adstock = items[indexPath.row]
        let name = Adstock.name ?? ""
        cell.textLabel?.text = "\(items[indexPath.row].adId!) \(name)"
        cell.textLabel?.font =  .appFont(.regular, size: 14)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(issearchtoggle){
            if(searchAds.count == 0)
               {
                searchAds = items
            }
            let Adstock = searchAds[indexPath.row]
            let name = Adstock.name ?? ""
            let adID = Adstock.adId ?? ""
            delegate?.didSelectStock(name, addID: adID)
        }
        else{
            let Adstock = items[indexPath.row]
            let name = Adstock.name ?? ""
            let adID = Adstock.adId ?? ""
            delegate?.didSelectStock(name, addID: adID)
        }
     
        dismiss(animated: true)
    }
}
extension StockInventoryView : UISearchBarDelegate {
    
}
