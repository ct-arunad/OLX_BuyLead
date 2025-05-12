//
//  LoadInventoryView.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 05/04/25.
//

import Foundation
import UIKit
public protocol InventoryTableViewDelegate: AnyObject {
    func didSelectInventory(_ item: String)
}
public class LoadInventoryView : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    public weak var delegate: InventoryTableViewDelegate?
    let searchBar = UISearchBar()

    private let tableView = UITableView()
    public var items: [Any] = []
    public var searchAds : [Any] = []
    var issearchtoggle = false

    public override func viewDidLoad() {
        self.view.backgroundColor = .white
        super.viewDidLoad()
        self.setupTableView()
        loadInventory()
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
    public func configure(with items: [Any]) {
        self.items = items
    }
    func loadInventory()
    {
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
        let parameters = [
            "action": "loadallematchinventory",
            "api_id": "cteolx2024v1.0",
            "device_id":Constant.uuid,
            "dealer_id":MyPodManager.user_id
            
        ] as! [String:Any]
        let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                DispatchQueue.main.async {
                    if  let dic = data["data"] as? NSDictionary{
                        self.items = (dic["cars"] as! NSArray) as! [Any]
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                }
            }
        }
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
        let image = UIImage.named("close")
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
       // print("Searching: \(searchText)")
         self.issearchtoggle = true

         if(searchText.count == 0){
             self.searchAds = self.items
         }
         else{
             let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
             let filtered = items.filter { predicate.evaluate(with: $0) }
             self.searchAds = filtered
         }
         self.tableView.reloadData()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.issearchtoggle = false
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
            let dic = searchAds[indexPath.item] as! NSDictionary
            print((dic["name"] as! String))
            cell.textLabel?.text = "\((dic["name"] as! String))"
            cell.textLabel?.font = .appFont(.regular, size: 14)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dic = items[indexPath.item] as! NSDictionary
        print((dic["name"] as! String))
        cell.textLabel?.text = "\((dic["name"] as! String))"
        cell.textLabel?.font =  .appFont(.regular, size: 14)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(issearchtoggle){
            if(searchAds.count == 0)
               {
                searchAds = items
               }
            let dic = searchAds[indexPath.item] as! NSDictionary
            delegate?.didSelectInventory(NSString(format: "%@", dic["id"] as! CVarArg) as String)
        }
        else{
            let dic = items[indexPath.item] as! NSDictionary
            delegate?.didSelectInventory(NSString(format: "%@", dic["id"] as! CVarArg) as String)
        }
        dismiss(animated: true)
    }
}
extension LoadInventoryView : UISearchBarDelegate {
    
}
